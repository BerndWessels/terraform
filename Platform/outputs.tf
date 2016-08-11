output "PlatformDelegationSetId" {
  value = "${aws_route53_delegation_set.Platform.id}"
}
output "PlatformHostedZoneId" {
  value = "${aws_route53_zone.Platform.id}"
}
output "PlatformWebsiteId" {
  value = "${aws_s3_bucket.PlatformWebsite.id}"
}
