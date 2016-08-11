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
 * Set of nameservers used for the platform domain.
 */
resource "aws_route53_delegation_set" "Platform" {
  reference_name = "${var.environment}"
}

/**
 * Hosted zone used for the platform domain.
 */
resource "aws_route53_zone" "Platform" {
  name = "${var.platform_domain}"
  delegation_set_id = "${aws_route53_delegation_set.Platform.id}"
}

/**
 * CNAME record used by the email provider to verfify the domain ownership.
 */
resource "aws_route53_record" "PlatformMailVerification" {
  zone_id = "${aws_route53_zone.Platform.zone_id}"
  name = "${var.email_domain_verification_cname_name}"
  type = "CNAME"
  ttl = "300"
  records = [
    "${var.email_domain_verification_cname_value}"]
}

/**
 * MX record pointing to the email provider.
 */
resource "aws_route53_record" "PlatformMail" {
  zone_id = "${aws_route53_zone.Platform.zone_id}"
  name = "${aws_route53_zone.Platform.name}"
  type = "MX"
  ttl = "300"
  records = [
    "${var.email_mx_record_values.1}",
    "${var.email_mx_record_values.2}"]
}

/**
 * Records routing to the CloudFront distribution of the platform website.
 */
resource "aws_route53_record" "PlatformWebsite" {
  zone_id = "${aws_route53_zone.Platform.zone_id}"
  name = "${aws_route53_zone.Platform.name}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.PlatformWebsite.domain_name}"
    zone_id = "${aws_cloudfront_distribution.PlatformWebsite.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "PlatformWebsiteWWW" {
  zone_id = "${aws_route53_zone.Platform.zone_id}"
  name = "www.${aws_route53_zone.Platform.name}"
  type = "CNAME"
  ttl = "300"
  records = [
    "${aws_route53_zone.Platform.name}"]
}

/**
 * CloudFront
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * CloudFront distribution of the platform website.
 */
resource "aws_cloudfront_distribution" "PlatformWebsite" {
  aliases = [
    "${var.platform_domain}",
    "www.${var.platform_domain}"]
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
    target_origin_id = "S3-${var.platform_domain}"
    viewer_protocol_policy = "redirect-to-https"
  }
  default_root_object = "index.html"
  enabled = true
  origin {
    domain_name = "${aws_s3_bucket.PlatformWebsite.bucket}.s3.amazonaws.com"
    origin_id = "S3-${var.platform_domain}"
    s3_origin_config {
    }
  }
  price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${var.platform_domain_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
  retain_on_delete = true
}

/**
 * S3
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * S3 bucket hosting the platform website.
 */
resource "aws_s3_bucket" "PlatformWebsite" {
  bucket = "${var.platform_domain}"
  acl = "public-read"
  policy = "${file("./Websites/Marketing/BucketPolicy.json")}"
  website {
    index_document = "index.html"
    routing_rules = "${file("./Websites/Marketing/RoutingRules.json")}"
  }
}

/**
 * IAM
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * IAM Role to enable APIGateway logging to CloudWatch.
 */
resource "aws_iam_role" "PlatformAPIGatewayAccount" {
  name = "platform_api_gateway_account"
  assume_role_policy = "${file("./CloudWatch/APIGateway/AssumeRolePolicy.json")}"
}

/**
 * IAM Role Policy to enable APIGateway logging to CloudWatch.
 */
resource "aws_iam_role_policy" "PlatformAPIGatewayAccount" {
  name = "platform_api_gateway_account"
  role = "${aws_iam_role.PlatformAPIGatewayAccount.id}"
  policy = "${file("./CloudWatch/APIGateway/InlinePolicy.json")}"
}

/**
 * IAM Role for the Platform GraphQL Lambda Function.
 */
resource "aws_iam_role" "PlatformLambdaGraphQLEndpoint" {
  name = "platform_lambda_graphql_endpoint"
  assume_role_policy = "${file("./Lambdas/GraphQLEndpoint/AssumeRolePolicy.json")}"
}

/**
 * IAM Role Policy for the Platform GraphQL Lambda Function.
 */
resource "aws_iam_role_policy" "PlatformLambdaGraphQLEndpoint" {
  name = "platform_lambda_graphql_endpoint"
  role = "${aws_iam_role.PlatformLambdaGraphQLEndpoint.id}"
  policy = "${file("./Lambdas/GraphQLEndpoint/InlinePolicy.json")}"
}

/**
 * Lambda
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * GraphQL Lambda Function.
 */
resource "aws_lambda_function" "PlatformGraphQL" {
  filename = "./Lambdas/GraphQLEndpoint/index.zip"
  function_name = "platform_graphql_endpoint"
  role = "${aws_iam_role.PlatformLambdaGraphQLEndpoint.arn}"
  handler = "index.handler"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("./Lambdas/GraphQLEndpoint/index.zip"))}"
}

/**
 * Allow APIGateway to access the GraphQL Lambda Function.
 */
resource "aws_lambda_permission" "PlatformGraphQL" {
  depends_on = [
    "aws_lambda_function.PlatformGraphQL"
  ]
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.PlatformGraphQL.function_name}"
  principal = "apigateway.amazonaws.com"
}

/**
 * API Gateway
 * -------------------------------------------------------------------------------------------------------------------
 */

/**
 * Enable APIGateway logging to CloudWatch.
 */
resource "aws_api_gateway_account" "Platform" {
  cloudwatch_role_arn = "${aws_iam_role.PlatformAPIGatewayAccount.arn}"
}

/**
 * GraphQL
 * ----------------------------------------------------------
 */

/**
 * REST API for the GraphQL Endpoint.
 */
resource "aws_api_gateway_rest_api" "PlatformAPI" {
  name = "platform_api"
  description = "Platform API"
  depends_on = [
    "aws_lambda_function.PlatformGraphQL"
  ]
}

/**
 * REST API Deployment for the GraphQL Endpoint.
 */
resource "aws_api_gateway_deployment" "PlatformGraphQL" {
  depends_on = [
    "aws_api_gateway_method.PlatformGraphQL",
    "aws_api_gateway_integration.PlatformGraphQL",
    "aws_api_gateway_integration_response.PlatformGraphQL",
    "aws_api_gateway_method_response.PlatformGraphQL"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.PlatformAPI.id}"
  stage_name = "prod"
}

/**
 * GraphQL REST Endpoint.
 */
resource "aws_api_gateway_resource" "PlatformGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.PlatformAPI.id}"
  parent_id = "${aws_api_gateway_rest_api.PlatformAPI.root_resource_id}"
  path_part = "graphql"
}

/**
 * GraphQL POST Method Request.
 */
resource "aws_api_gateway_method" "PlatformGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.PlatformAPI.id}"
  resource_id = "${aws_api_gateway_resource.PlatformGraphQL.id}"
  http_method = "POST"
  authorization = "NONE"
}

/**
 * GraphQL POST Integration Request.
 */
resource "aws_api_gateway_integration" "PlatformGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.PlatformAPI.id}"
  resource_id = "${aws_api_gateway_resource.PlatformGraphQL.id}"
  http_method = "${aws_api_gateway_method.PlatformGraphQL.http_method}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.PlatformGraphQL.arn}/invocations"
  integration_http_method = "${aws_api_gateway_method.PlatformGraphQL.http_method}"
}

/**
 * GraphQL POST Integration Response for status 200.
 */
resource "aws_api_gateway_integration_response" "PlatformGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.PlatformAPI.id}"
  resource_id = "${aws_api_gateway_resource.PlatformGraphQL.id}"
  http_method = "${aws_api_gateway_method.PlatformGraphQL.http_method}"
  status_code = "${aws_api_gateway_method_response.PlatformGraphQL.status_code}"
}

/**
 * GraphQL POST Method Response for status 200.
 */
resource "aws_api_gateway_method_response" "PlatformGraphQL" {
  rest_api_id = "${aws_api_gateway_rest_api.PlatformAPI.id}"
  resource_id = "${aws_api_gateway_resource.PlatformGraphQL.id}"
  http_method = "${aws_api_gateway_method.PlatformGraphQL.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}
