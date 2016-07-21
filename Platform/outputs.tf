output "PlatformDelegationSetId" {
  value = "${module.PlatformDelegationSet.delegationSetId}"
}

output "PlatformHostedZoneId" {
  value = "${aws_route53_zone.PlatformHostedZone.id}"
}
