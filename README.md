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
