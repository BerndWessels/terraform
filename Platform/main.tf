# The Set of Nameservers for ?this? Product Domain.
module "PlatformDelegationSet" {
  source = "../DelegationSet"
  aws_region = "${var.aws_region}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  environment = "${var.environment}"
}
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
resource "aws_route53_zone" "PlatformHostedZone" {
  name = "${var.platform_domain}"
  delegation_set_id = "${module.PlatformDelegationSet.delegationSetId}"
}
