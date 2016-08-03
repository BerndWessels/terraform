/**
 * AWS region and credentials.
 */
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
/**
 * Set of nameservers used for the platform domain.
 */
resource "aws_route53_delegation_set" "PlatformDelegationSet" {
  reference_name = "${var.environment}"
}
/**
 * Hosted zone used for the platform domain.
 */
resource "aws_route53_zone" "PlatformHostedZone" {
  name = "${var.platform_domain}"
  delegation_set_id = "${aws_route53_delegation_set.PlatformDelegationSet.id}"
}
/**
 * CNAME record used by the email provider to verfify the domain ownership.
 */
resource "aws_route53_record" "PlatformMailVerificationRecord" {
  zone_id = "${aws_route53_zone.PlatformHostedZone.zone_id}"
  name = "${var.email_domain_verification_cname_name}"
  type = "CNAME"
  ttl = "300"
  records = [
    "${var.email_domain_verification_cname_value}"]
}
/**
 * MX record pointing to the email provider.
 */
resource "aws_route53_record" "PlatformMailMxRecord" {
  zone_id = "${aws_route53_zone.PlatformHostedZone.zone_id}"
  name = "${aws_route53_zone.PlatformHostedZone.name}"
  type = "MX"
  ttl = "300"
  records = [
    "${var.email_mx_record_values.1}",
    "${var.email_mx_record_values.2}"]
}
/**
 * S3 bucket hosting the platform website.
 */
resource "aws_s3_bucket" "PlatformWebsiteBucket" {
  bucket = "${var.platform_domain}"
  acl = "public-read"
  policy = "${file("./Websites/Marketing/BucketPolicy.json")}"
  website {
    index_document = "index.html"
    routing_rules = "${file("./Websites/Marketing/RoutingRules.json")}"
  }
}
/**
 * CloudFront distribution of the platform website.
 */
resource "aws_cloudfront_distribution" "PlatformWebsiteDistribution" {
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
    domain_name = "${aws_s3_bucket.PlatformWebsiteBucket.bucket}.s3.amazonaws.com"
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
}
/**
 * Records routing to the CloudFront distribution of the platform website.
 */
resource "aws_route53_record" "PlatformWebsiteRecord1" {
  zone_id = "${aws_route53_zone.PlatformHostedZone.zone_id}"
  name = "${aws_route53_zone.PlatformHostedZone.name}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.PlatformWebsiteDistribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.PlatformWebsiteDistribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "PlatformWebsiteRecord2" {
  zone_id = "${aws_route53_zone.PlatformHostedZone.zone_id}"
  name = "www.${aws_route53_zone.PlatformHostedZone.name}"
  type = "A"
  alias {
    name = "${aws_cloudfront_distribution.PlatformWebsiteDistribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.PlatformWebsiteDistribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}