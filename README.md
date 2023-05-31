# splits-utils

## What

Utilities re-used across the splits ecosystem

```
AddressUtils - helper functions on addresses
ConvertedQuotePair - sort converted quotes
LibClone - modified minimal clone
LibQuotes - sort & convert quotes
LibRecipients - efficiently sorting splits' recipients onchain
OwnableImpl - minimal ownable clone-implementation
PausableImpl - minimal pausable clone-implementation
TokenUtils - helper functions on tokens (including ETH as 0x0)
WalletImpl - minimal smart wallet clone-implementation
```

## Why

To ease external integrations and re-use frequent development / testing patterns

## Lint

`forge fmt`

## Setup & test

`forge i` - install dependencies

`forge b` - compile the contracts

`forge t` - compile & test the contracts

`forge t -vvv` - produce traces for any failing tests

### Natspec

`forge doc --serve --port 4000` - serves natspec docs at http://localhost:4000/
