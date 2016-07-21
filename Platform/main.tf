# The Set of Nameservers for ?this? Product Domain.
module "PlatformDelegationSet" {
  source = "../DelegationSet"
  aws_region = "${var.aws_region}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  environment = "${var.environment}"
}
