# Charitable Donations and Impact Tracking Smart Contract

## Overview

This Clarity-based smart contract is designed to manage charitable donations, track the total amount of donations, and manage donation targets. The contract allows individuals to donate, set donation targets, and request refunds. It also enables tracking of each donation's status and ensures the integrity of the donation process.

Key features of the contract:
- Donation management (donate, increase donation, refund).
- Donation target setting and progress tracking.
- Secure donation tracking with unique donation IDs.
- Ability for donors to request refunds (with conditions).

## Contract Functions

### Constants
The contract defines several constants for error handling and ensures the proper execution of functions:
- `contract-owner`: The principal that owns the contract and has the privilege to modify certain variables.
- `err-*`: Various error constants used for validation, such as `err-invalid-amount`, `err-donation-not-found`, `err-donation-exceeds-target`, etc.

### Data Variables
- `last-donation-id`: Tracks the last donation ID, which is incremented for each new donation.
- `total-donations`: The total amount of donations received.
- `donation-target`: The target amount for donations, set by the contract owner.

### Maps
- `donation-records`: A map that holds donation records by donation ID. Each record includes:
  - `amount`: The amount donated.
  - `donor`: The principal who made the donation.
  - `refunded`: A flag indicating whether the donation has been refunded.

## Public Functions

### `donate (amount uint)`
This function allows a user to donate a specified amount. It ensures that the donation is a valid amount, stores the donation record, updates the total donations, and checks whether the donation goal has been met.

#### Inputs:
- `amount`: The donation amount in the smallest unit of the currency.

#### Outputs:
- The donation ID assigned to the new donation.

### `increase-donation (donation-id uint, additional-amount uint)`
This function allows a donor to increase their donation by adding an additional amount to an existing donation.

#### Inputs:
- `donation-id`: The ID of the donation being increased.
- `additional-amount`: The additional amount to add to the existing donation.

#### Outputs:
- The new total donation amount for the given `donation-id`.

### `set-donation-target (target uint)`
This function allows the contract owner to set the donation target. It validates the target and ensures that it is greater than the current total donations.

#### Inputs:
- `target`: The new donation target.

#### Outputs:
- The updated donation target.

### `get-donation-details (donation-id uint)`
This function retrieves the details of a specific donation, including the amount, donor, and refund status.

#### Inputs:
- `donation-id`: The ID of the donation.

#### Outputs:
- A record containing the donation details, or an error if the donation ID is invalid.

### `get-total-donations`
This function returns the total amount of donations received by the contract.

#### Outputs:
- The total donations collected.

### `get-donation-target`
This function returns the current donation target.

#### Outputs:
- The current donation target.

### `get-last-donation-id`
This function returns the ID of the most recent donation.

#### Outputs:
- The last donation ID.

### `request-refund (donation-id uint)`
This function allows a donor to request a refund for a donation. It validates that the donor is the one who made the donation and ensures that the donation hasn't been refunded and hasn't contributed to the target.

#### Inputs:
- `donation-id`: The ID of the donation for which the refund is requested.

#### Outputs:
- The refunded amount if the request is successful, or an error if not.

### `get-donations-for-donor (donor principal)`
This function allows a donor to retrieve all donations made by them. It returns a list of donation IDs made by the given donor.

#### Inputs:
- `donor`: The principal who made the donations.

#### Outputs:
- A list of donation IDs associated with the donor.

## Private Functions

### `is-valid-donation-amount (amount uint)`
Ensures that the donation amount is positive.

### `is-valid-target (target uint)`
Checks if the target is greater than the total donations.

### `is-valid-donation-id (donation-id uint)`
Checks if the donation ID exists.

### `get-donation (donation-id uint)`
Retrieves the donation record for a given ID.

### `has-reached-target`
Checks if the total donations have reached the target.

## Error Handling
The contract includes the following error conditions:
- `err-owner-only`: Raised when a non-owner tries to perform an owner-only action.
- `err-invalid-amount`: Raised when an invalid donation amount is provided.
- `err-donation-not-found`: Raised when the specified donation ID is not found.
- `err-donation-exceeds-target`: Raised when the total donations exceed the donation target.
- `err-invalid-target`: Raised when an invalid donation target is provided.
- `err-invalid-donation-id`: Raised when an invalid donation ID is provided.
- `err-refund-not-allowed`: Raised when a refund is not allowed under the contract conditions.
- `err-donation-id-mismatch`: Raised when a donor attempts to modify or refund a donation they did not make.

## Contract Initialization
The contract initializes with:
- `last-donation-id`: Set to 0.
- `total-donations`: Set to 0.

## Deployment and Usage
To deploy this contract, use the standard Clarity contract deployment procedure. Once deployed, the contract owner can set the donation target and manage donations. Donors can make donations, increase them, or request refunds as per the rules outlined in the contract.

## Example Usage

### Making a Donation
```clarity
(donate 500)
```

### Increasing a Donation
```clarity
(increase-donation 1 200)
```

### Setting a Donation Target
```clarity
(set-donation-target 10000)
```

### Requesting a Refund
```clarity
(request-refund 1)
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

```

This README provides a clear, detailed description of the contract's functionality, including its constants, variables, functions, error handling, and usage examples. It is organized in a way that is informative for developers looking to deploy or interact with this contract.