# tldr;

- This repo contains everything to spin up new production / development / test environments on AWS.
- The idea here is that production / development / test environments should be almost identical.
- To spin up a new environment you either create a new `branch` or `fork` of your `master`.
Then you create a new AWS account, update the configuration files and deploy your new environment.
- Batteries included and completely serverless*:
  - Websites for your domain via S3 Bucket, CloudFront Distribution, Route53 DNS, ACM Certificate.
  - React, Webpack.
  - React-Native App.
  - GraphQL Lambda Backend.
  - Cognito Indentity and User Pools.
  - ...

# Platform vs. Products

To demonstrate all the complexity around enterprise environments this repo has two logical parts.

## Platform
The platform contains the public marketing page and can be branded, so that you can resell the complete platform.

## Products
The products are the actual services within the platform offering and contain the private web and mobile apps.

# Platform Environment Setup

## Domain

Register a domain and make sure to provide valid contact details!
Set the domain in the `.platform.tfvars file`.

## EMail Provider

Register the domain with an email provider like `zoho.com`.

Get the `CNAME` name and value from the provider to verify the domain ownership.
Set these in your `.platform.tfvars file`.

## Domain Certificate

Use the AWS Certificate Manager to request a new certificate.
Include the `domain.com` and `www.domain.com` in the certificate.

This will send a confirmation email for each included domain to your registered domain contact details.
Confirm both emails and in the AWS Certificate Manager check that the certificate has status `issued`.

Get the ARN of the certificate and set it in you `.platform.tfvars` file.

## Build

...

## Deploy

...

`terraform plan`

`terraform apply`

...

# Production Environments / Accounts

For each `Production Environment` there is a dedicated `AWS Account`.
 
## Manapaho

This is the `Manapaho Platform` Marketing and Administration.

### `DelegationSet` for `manapaho.com`

### `HostedZone` using the `manapaho.com` `DelegationSet`:

            manapaho.com
        www.manapaho.com

## BNZ

This is a `Direct Customer` on the `Manapaho Platform`.

### `HostedZone` using the `manapaho.com` `DelegationSet` via `cross account resource access`:

        bnz.manapaho.com
    www.bnz.manapaho.com
      *.bnz.manapaho.com        fonterra.bnz.manapaho.com

## Wessels

This is a `Platform Reseller`. Selling the platform as `Wessels Platform` to its own customers.

### `DelegationSet` for `wessels.com`
### `DelegationSet` for `westpac-q.com`

### `HostedZone` using the `wessels.com` `DelegationSet`:

            wessels.com
        www.wessels.com

## ANZ

This is a `Direct Customer` on the `Wessels Platform`.

### `HostedZone` using the `wessels.com` `DelegationSet`:

        anz.wessels.com
    www.anz.wessels.com
      *.anz.wessels.com        barfoot.anz.wessels.com

## WestPack Q

This is a `Direct Customer` on the `Wessels Platform` bringing their own domain.

### `HostedZone` using the `westpack-q.com` `DelegationSet`:

        westpack-q.com
    www.westpack-q.com
      *.westpack-q.com        farmhouse.westpack-q.com

# Development Environments / Accounts

For each `Development Environment` there is a dedicated `AWS Account`.

## Manapaho Development

Every development will be made using the `manapaho-dev.com` domain.

### `DelegationSet` for `manapaho-dev.com`

## Manapaho

### `HostedZone` using the `manapaho-dev.com` `DelegationSet`:

                        manapaho-dev.com
                    www.manapaho-dev.com

## Wessels

### `HostedZone` using the `manapaho-dev.com` `DelegationSet`:

                        wessels.manapaho-dev.com
                    www.wessels.manapaho-dev.com

## ANZ

### `HostedZone` using the `manapaho-dev.com` `DelegationSet`:

                    anz.wessels.manapaho-dev.com
                www.anz.wessels.manapaho-dev.com
                  *.anz.wessels.manapaho-dev.com

## New Car Wizard Feature

### `HostedZone` using the `manapaho-dev.com` `DelegationSet`:

        new-card-wizard-feature.wessels.manapaho-dev.com
    www.new-card-wizard-feature.wessels.manapaho-dev.com
      *.new-card-wizard-feature.wessels.manapaho-dev.com
