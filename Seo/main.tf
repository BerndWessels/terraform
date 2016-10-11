/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

/**
 * AWS region and credentials.
 * -------------------------------------------------------------------------------------------------------------------
 */
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

/**
 * Helper to get the current Account ID via ${data.aws_caller_identity.current.account_id}
 */
data "aws_caller_identity" "current" {
}

/**
 * Route53
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * Set of nameservers used for the Seo domains.
 */
resource "aws_route53_delegation_set" "Seo" {
  reference_name = "${var.environment}"
}

/**
 * Seo domain
 * ----------------------------------------------------------
 */

/**
 * Hosted zone used for the Seo domain.
 */
resource "aws_route53_zone" "Seo" {
  name = "${var.seo_domain}"
  delegation_set_id = "${aws_route53_delegation_set.Seo.id}"
}

/**
 * Record routing to the APIGateway's CloudFront distribution for the Seo website.
 */
resource "aws_route53_record" "SeoWebsite" {
  zone_id = "${aws_route53_zone.Seo.zone_id}"
  name = "${var.seo_domain}"
  type = "A"
  alias {
    name = "${aws_api_gateway_domain_name.SeoWebsite.cloudfront_domain_name}"
    zone_id = "${aws_api_gateway_domain_name.SeoWebsite.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

/**
 * Seo resources domain
 * ----------------------------------------------------------
 */

/**
 * Hosted zone used for the Seo domain.
 */
resource "aws_route53_zone" "SeoResources" {
  name = "${var.seo_resources_domain}"
  delegation_set_id = "${aws_route53_delegation_set.Seo.id}"
}

/**
 * Record routing to the CloudFront distribution of the Seo resources website.
 */
resource "aws_route53_record" "SeoResourcesWebsite" {
  zone_id = "${aws_route53_zone.SeoResources.zone_id}"
  name = "${var.seo_resources_domain}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.SeoResourcesWebsite.domain_name}"
    zone_id = "${aws_cloudfront_distribution.SeoResourcesWebsite.hosted_zone_id}"
    evaluate_target_health = false
  }
}

/**
 * CloudFront
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * CloudFront distribution of the Seo resources website.
 */
resource "aws_cloudfront_distribution" "SeoResourcesWebsite" {
  aliases = [
    "${var.seo_resources_domain}"
  ]
  comment = "Managed by Terraform"
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD"]
    cached_methods = [
      "GET",
      "HEAD"]
    compress = true
    default_ttl = 30
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    max_ttl = 86400
    min_ttl = 0
    target_origin_id = "S3-${var.seo_resources_domain}"
    viewer_protocol_policy = "redirect-to-https"
  }
  default_root_object = "index.html"
  enabled = true
  origin {
    domain_name = "${aws_s3_bucket.SeoResourcesWebsite.bucket}.s3.amazonaws.com"
    origin_id = "S3-${var.seo_resources_domain}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.SeoResourcesWebsite.cloudfront_access_identity_path}"
    }
  }
  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${var.seo_resources_domain_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
  retain_on_delete = true
}

/**
 * Origin Identity to workaround https://github.com/hashicorp/terraform/issues/7930
 */
resource "aws_cloudfront_origin_access_identity" "SeoResourcesWebsite" {
  comment = "Managed by Terraform"
}

/**
 * S3
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * S3 bucket hosting the Seo website.
 */
resource "aws_s3_bucket" "SeoResourcesWebsite" {
  bucket = "${var.seo_resources_domain}"
  acl = "public-read"
  policy = "${file("./Websites/SeoResources/BucketPolicy.json")}"
  website {
    index_document = "index.html"
    routing_rules = "${file("./Websites/SeoResources/RoutingRules.json")}"
  }
}

/**
 * IAM
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * IAM Role to enable APIGateway logging to CloudWatch.
 */
resource "aws_iam_role" "SeoAPIGatewayAccount" {
  name = "seo_api_gateway_account"
  assume_role_policy = "${file("./CloudWatch/APIGateway/AssumeRolePolicy.json")}"
}

/**
 * IAM Role Policy to enable APIGateway logging to CloudWatch.
 */
resource "aws_iam_role_policy" "SeoAPIGatewayAccount" {
  name = "seo_api_gateway_account"
  role = "${aws_iam_role.SeoAPIGatewayAccount.id}"
  policy = "${file("./CloudWatch/APIGateway/InlinePolicy.json")}"
}

/**
 * IAM Role for the Seo Website Lambda Function.
 */
resource "aws_iam_role" "SeoLambdaWebsiteEndpoint" {
  name = "seo_lambda_website_endpoint"
  assume_role_policy = "${file("./Lambdas/WebsiteEndpoint/AssumeRolePolicy.json")}"
}

/**
 * IAM Role Policy for the Seo Website Lambda Function.
 */
resource "aws_iam_role_policy" "SeoLambdaWebsiteEndpoint" {
  name = "seo_lambda_website_endpoint"
  role = "${aws_iam_role.SeoLambdaWebsiteEndpoint.id}"
  policy = "${file("./Lambdas/WebsiteEndpoint/InlinePolicy.json")}"
}

/**
 * Lambda
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * Website Lambda Function.
 */
resource "aws_lambda_function" "SeoWebsite" {
  filename = "./Lambdas/WebsiteEndpoint/.WebsiteEndpoint.compiled.zip"
  function_name = "seo_website_endpoint"
  role = "${aws_iam_role.SeoLambdaWebsiteEndpoint.arn}"
  handler = "index.handler"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("./Lambdas/WebsiteEndpoint/.WebsiteEndpoint.compiled.zip"))}"
}

/**
 * Allow APIGateway to access the Website Lambda Function.
 */
resource "aws_lambda_permission" "SeoWebsiteApiGatewayMethod" {
  depends_on = [
    "aws_api_gateway_method.SeoWebsite",
    "aws_api_gateway_method_response.SeoWebsite"
  ]
  statement_id = "AllowExecutionFromAPIGatewayMethod"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.SeoWebsite.function_name}"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.SeoWebsite.id}/*/*/"
}

/**
 * API Gateway
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * Enable APIGateway logging to CloudWatch.
 */
resource "aws_api_gateway_account" "Seo" {
  cloudwatch_role_arn = "${aws_iam_role.SeoAPIGatewayAccount.arn}"
}

/**
 * Domain
 * ----------------------------------------------------------
 */

/**
 * Custom domain name for the Website Endpoint.
 */
resource "aws_api_gateway_domain_name" "SeoWebsite" {
  domain_name = "${var.seo_domain}"
  certificate_name = "${var.seo_domain}"
  certificate_body = "${file("./Certificates/${var.seo_domain}.crt")}"
  certificate_chain = "${file("./Certificates/${var.seo_domain}.chain.crt")}"
  certificate_private_key = "${file("./Certificates/${var.seo_domain}.key")}"
}

/**
 * Custom domain base path mapping for the Website Endpoint.
 */
resource "aws_api_gateway_base_path_mapping" "SeoWebsite" {
  api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
  stage_name = "${aws_api_gateway_deployment.SeoWebsite.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.SeoWebsite.domain_name}"
  base_path = "(none)"
}

/**
 * Website
 * ----------------------------------------------------------
 */

/**
 * REST API for the Website Endpoint.
 */
resource "aws_api_gateway_rest_api" "SeoWebsite" {
  name = "seo_website"
  description = "Seo Website"
  depends_on = [
    "aws_lambda_function.SeoWebsite"
  ]
}

/**
 * REST API Deployment for the Website Endpoint.
 */
resource "aws_api_gateway_deployment" "SeoWebsite" {
  depends_on = [
    "aws_api_gateway_method.SeoWebsite",
    "aws_api_gateway_integration.SeoWebsite"
    //"aws_api_gateway_integration_response.SeoWebsite",
    //"aws_api_gateway_method_response.SeoWebsite"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
  stage_name = "prod"
}

/**
 * API root (/)
 * -----------------------------
 */

/**
 * Website GET Method Request.
 */
resource "aws_api_gateway_method" "SeoWebsite" {
  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
  resource_id = "${aws_api_gateway_rest_api.SeoWebsite.root_resource_id}"
  http_method = "ANY"
  authorization = "NONE"
}

/**
 * Website GET Integration Request.
 */
resource "aws_api_gateway_integration" "SeoWebsite" {
  depends_on = [
    "aws_lambda_permission.SeoWebsiteApiGatewayMethod"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
  resource_id = "${aws_api_gateway_rest_api.SeoWebsite.root_resource_id}"
  http_method = "${aws_api_gateway_method.SeoWebsite.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.SeoWebsite.arn}/invocations"
  integration_http_method = "POST" // Lambda function do only accept POST
}

/**
 * Website GET Integration Response for status 200.
 */
resource "aws_api_gateway_integration_response" "SeoWebsite" {
  depends_on = [
    "aws_api_gateway_integration.SeoWebsite"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
  resource_id = "${aws_api_gateway_rest_api.SeoWebsite.root_resource_id}"
  http_method = "${aws_api_gateway_method.SeoWebsite.http_method}"
  status_code = "${aws_api_gateway_method_response.SeoWebsite.status_code}"
}

/**
 * Website GET Method Response for status 200.
 */
resource "aws_api_gateway_method_response" "SeoWebsite" {
  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
  resource_id = "${aws_api_gateway_rest_api.SeoWebsite.root_resource_id}"
  http_method = "${aws_api_gateway_method.SeoWebsite.http_method}"
  status_code = "200"
  response_models = {
    "text/html" = "Empty"
  }
}

///**
// * API proxy (/*)
// * -----------------------------
// */
//
///**
// * Website REST Endpoint.
// */
//resource "aws_api_gateway_resource" "SeoWebsiteProxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
//  parent_id = "${aws_api_gateway_rest_api.SeoWebsite.root_resource_id}"
//  path_part = "{proxy+}"
//}
//
///**
// * Website GET Method Request.
// */
//resource "aws_api_gateway_method" "SeoWebsiteProxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
//  resource_id = "${aws_api_gateway_resource.SeoWebsiteProxy.id}"
//  http_method = "GET"
//  authorization = "NONE"
//}
//
///**
// * Website POST Integration Request. TODO: type = "AWS_PROXY"
// */
//resource "aws_api_gateway_integration" "SeoWebsiteProxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
//  resource_id = "${aws_api_gateway_resource.SeoWebsiteProxy.id}"
//  http_method = "${aws_api_gateway_method.SeoWebsiteProxy.http_method}"
//  type = "AWS"
//  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.SeoWebsite.arn}/invocations"
//  integration_http_method = "${aws_api_gateway_method.SeoWebsiteProxy.http_method}"
//}
//
///**
// * Website POST Integration Response for status 200.
// */
//resource "aws_api_gateway_integration_response" "SeoWebsiteProxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
//  resource_id = "${aws_api_gateway_resource.SeoWebsiteProxy.id}"
//  http_method = "${aws_api_gateway_method.SeoWebsiteProxy.http_method}"
//  status_code = "${aws_api_gateway_method_response.SeoWebsiteProxy.status_code}"
//}
//
///**
// * Website POST Method Response for status 200.
// */
//resource "aws_api_gateway_method_response" "SeoWebsiteProxy" {
//  rest_api_id = "${aws_api_gateway_rest_api.SeoWebsite.id}"
//  resource_id = "${aws_api_gateway_resource.SeoWebsiteProxy.id}"
//  http_method = "${aws_api_gateway_method.SeoWebsiteProxy.http_method}"
//  status_code = "200"
//  response_models = {
//    "text/html" = "Empty"
//  }
//}
