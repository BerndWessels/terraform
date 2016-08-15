/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

output "PlatformDelegationSetId" {
  value = "${aws_route53_delegation_set.Platform.id}"
}
output "PlatformHostedZoneId" {
  value = "${aws_route53_zone.Platform.id}"
}
output "PlatformWebsiteId" {
  value = "${aws_s3_bucket.PlatformWebsite.id}"
}
