output "PlatformDelegationSetId" {
  value = "${aws_route53_delegation_set.PlatformDelegationSet.id}"
}
output "PlatformHostedZoneId" {
  value = "${aws_route53_zone.PlatformHostedZone.id}"
}
output "PlatformWebsiteBucketId" {
  value = "${aws_s3_bucket.PlatformWebsiteBucket.id}"
}
