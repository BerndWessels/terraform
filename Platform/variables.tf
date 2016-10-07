/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

variable "aws_region" {
  type = "string"
  description = "The AWS region."
  default = "us-east-1"
}
variable "aws_access_key" {
  type = "string"
  description = "The AWS access key."
}
variable "aws_secret_key" {
  type = "string"
  description = "The AWS secret key"
}
variable "environment" {
  type = "string"
  description = "The environment/account name."
}
variable "platform_domain" {
  type = "string"
  description = "The fully qualified platform domain name."
}
variable "email_domain_verification_cname_name" {
  type = "string"
  description = "The name of the CNAME record used by the email provider to verify the domain ownership."
}
variable "email_domain_verification_cname_value" {
  type = "string"
  description = "The value of the CNAME record used by the email provider to verify the domain ownership."
}
variable "email_mx_record_values" {
  type = "map"
  description = "The values of the MX record used to point to the email provider."
  default = {}
}
variable "platform_domain_certificate_arn" {
  type = "string"
  description = "The ARN of the ACM certificate to be used for the platform website distribution."
}
variable "product_domain" {
  type = "string"
  description = "The fully qualified product domain name."
}
variable "product_subdomain_ns_record_values" {
  type = "map"
  description = "The values of the NS record pointing to the product nameservers."
  default = {}
}
variable "seo_domain" {
  type = "string"
  description = "The fully qualified seo domain name."
}
variable "seo_resources_domain" {
  type = "string"
  description = "The fully qualified seo resources domain name."
}
variable "seo_subdomain_ns_record_values" {
  type = "map"
  description = "The values of the NS record pointing to the seo nameservers."
  default = {}
}
