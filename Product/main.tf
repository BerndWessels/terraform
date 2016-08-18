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
 * Route53
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * Set of nameservers used for the product domain.
 */
resource "aws_route53_delegation_set" "Product" {
  reference_name = "${var.environment}"
}

/**
 * Hosted zone used for the product domain.
 */
resource "aws_route53_zone" "Product" {
  name = "${var.product_domain}"
  delegation_set_id = "${aws_route53_delegation_set.Product.id}"
}

/**
 * CNAME record used by the email provider to verfify the domain ownership.
 */
resource "aws_route53_record" "ProductMailVerification" {
  zone_id = "${aws_route53_zone.Product.zone_id}"
  name = "${var.email_domain_verification_cname_name}"
  type = "CNAME"
  ttl = "300"
  records = [
    "${var.email_domain_verification_cname_value}"]
}

/**
 * MX record pointing to the email provider.
 */
resource "aws_route53_record" "ProductMail" {
  zone_id = "${aws_route53_zone.Product.zone_id}"
  name = "${aws_route53_zone.Product.name}"
  type = "MX"
  ttl = "300"
  records = [
    "${var.email_mx_record_values.1}",
    "${var.email_mx_record_values.2}"]
}

/**
 * Records routing to the CloudFront distribution of the product website.
 */
resource "aws_route53_record" "ProductWebsite" {
  zone_id = "${aws_route53_zone.Product.zone_id}"
  name = "${aws_route53_zone.Product.name}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.ProductWebsite.domain_name}"
    zone_id = "${aws_cloudfront_distribution.ProductWebsite.hosted_zone_id}"
    evaluate_target_health = false
  }
}

/**
 * CloudFront
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * CloudFront distribution of the product website.
 */
resource "aws_cloudfront_distribution" "ProductWebsite" {
  aliases = [
    "${var.product_domain}"
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
    target_origin_id = "S3-${var.product_domain}"
    viewer_protocol_policy = "redirect-to-https"
  }
  default_root_object = "index.html"
  enabled = true
  origin {
    domain_name = "${aws_s3_bucket.ProductWebsite.bucket}.s3.amazonaws.com"
    origin_id = "S3-${var.product_domain}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.ProductWebsite.cloudfront_access_identity_path}"
    }
  }
  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${var.product_domain_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
  retain_on_delete = true
}

/**
 * Origin Identity to workaround https://github.com/hashicorp/terraform/issues/7930
 */
resource "aws_cloudfront_origin_access_identity" "ProductWebsite" {
  comment = "Managed by Terraform"
}

/**
 * S3
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * S3 bucket hosting the product website.
 */
resource "aws_s3_bucket" "ProductWebsite" {
  bucket = "${var.product_domain}"
  acl = "public-read"
  policy = "${file("./Websites/Feature/BucketPolicy.json")}"
  website {
    index_document = "index.html"
    routing_rules = "${file("./Websites/Feature/RoutingRules.json")}"
  }
}

/**
 * IAM
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * IAM Role to enable APIGateway logging to CloudWatch.
 */
resource "aws_iam_role" "ProductAPIGatewayAccount" {
  name = "product_api_gateway_account"
  assume_role_policy = "${file("./CloudWatch/APIGateway/AssumeRolePolicy.json")}"
}

/**
 * IAM Role Policy to enable APIGateway logging to CloudWatch.
 */
resource "aws_iam_role_policy" "ProductAPIGatewayAccount" {
  name = "product_api_gateway_account"
  role = "${aws_iam_role.ProductAPIGatewayAccount.id}"
  policy = "${file("./CloudWatch/APIGateway/InlinePolicy.json")}"
}

/**
 * IAM Role for the Product GraphQL Lambda Function.
 */
resource "aws_iam_role" "ProductLambdaGraphQLEndpoint" {
  name = "product_lambda_graphql_endpoint"
  assume_role_policy = "${file("./Lambdas/GraphQLEndpoint/AssumeRolePolicy.json")}"
}

/**
 * IAM Role Policy for the Product GraphQL Lambda Function.
 */
resource "aws_iam_role_policy" "ProductLambdaGraphQLEndpoint" {
  name = "product_lambda_graphql_endpoint"
  role = "${aws_iam_role.ProductLambdaGraphQLEndpoint.id}"
  policy = "${file("./Lambdas/GraphQLEndpoint/InlinePolicy.json")}"
}

/**
 * Lambda
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * GraphQL Lambda Function.
 */
resource "aws_lambda_function" "ProductGraphQL" {
  filename = "./Lambdas/GraphQLEndpoint/.GraphQLEndpoint.compiled.zip"
  function_name = "product_graphql_endpoint"
  role = "${aws_iam_role.ProductLambdaGraphQLEndpoint.arn}"
  handler = "index.handler"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("./Lambdas/GraphQLEndpoint/.GraphQLEndpoint.compiled.zip"))}"
}

/**
 * Allow APIGateway to access the GraphQL Lambda Function.
 */
resource "aws_lambda_permission" "ProductGraphQL" {
  depends_on = [
    "aws_lambda_function.ProductGraphQL"
  ]
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ProductGraphQL.function_name}"
  principal = "apigateway.amazonaws.com"
}

/**
 * API Gateway
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * Enable APIGateway logging to CloudWatch.
 */
resource "aws_api_gateway_account" "Product" {
  cloudwatch_role_arn = "${aws_iam_role.ProductAPIGatewayAccount.arn}"
}

/**
 * GraphQL
 * ----------------------------------------------------------
 */

/**
 * REST API for the GraphQL Endpoint.
 */
resource "aws_api_gateway_rest_api" "ProductAPI" {
  name = "product_api"
  description = "Product API"
  depends_on = [
    "aws_lambda_function.ProductGraphQL"
  ]
}

/**
 * REST API Deployment for the GraphQL Endpoint.
 */
resource "aws_api_gateway_deployment" "ProductGraphQL" {
  depends_on = [
    "aws_api_gateway_method.ProductGraphQL",
    "aws_api_gateway_integration.ProductGraphQL",
    "aws_api_gateway_integration_response.ProductGraphQL",
    "aws_api_gateway_method_response.ProductGraphQL"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.ProductAPI.id}"
  stage_name = "prod"
}

/**
 * GraphQL REST Endpoint.
 */
resource "aws_api_gateway_resource" "ProductGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.ProductAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.ProductAPI.root_resource_id}"
  path_part = "graphql"
}

/**
 * GraphQL POST Method Request.
 */
resource "aws_api_gateway_method" "ProductGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.ProductAPI.id}"
  resource_id = "${aws_api_gateway_resource.ProductGraphQL.id}"
  http_method = "POST"
  authorization = "NONE"
}

/**
 * GraphQL POST Integration Request.
 */
resource "aws_api_gateway_integration" "ProductGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.ProductAPI.id}"
  resource_id = "${aws_api_gateway_resource.ProductGraphQL.id}"
  http_method = "${aws_api_gateway_method.ProductGraphQL.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.ProductGraphQL.arn}/invocations"
  integration_http_method = "${aws_api_gateway_method.ProductGraphQL.http_method}"
}

/**
 * GraphQL POST Integration Response for status 200.
 */
resource "aws_api_gateway_integration_response" "ProductGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.ProductAPI.id}"
  resource_id = "${aws_api_gateway_resource.ProductGraphQL.id}"
  http_method = "${aws_api_gateway_method.ProductGraphQL.http_method}"
  status_code = "${aws_api_gateway_method_response.ProductGraphQL.status_code}"
}

/**
 * GraphQL POST Method Response for status 200.
 */
resource "aws_api_gateway_method_response" "ProductGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.ProductAPI.id}"
  resource_id = "${aws_api_gateway_resource.ProductGraphQL.id}"
  http_method = "${aws_api_gateway_method.ProductGraphQL.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}
