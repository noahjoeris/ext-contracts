# Crowdfunding Documentation

## Overview

This document describes the implementation and functionality of two Solidity smart contracts designed to manage fundraising campaigns on the Ethereum blockchain. Both contracts utilize OpenZeppelin libraries to ensure robust security features. The contracts enable multiple fundraising campaigns, each with its own funding target, contribution tracking, and owner-controlled operations.

### Key Features

- **Modularity**: Two versions of the fundraising contract are available: an upgradeable version (`FundraiserUpgradeable`) and a standard version (`Fundraiser`).
- **Security and Upgradeability**: Using OpenZeppelin's upgradeable contracts for the `FundraiserUpgradeable` to allow future improvements without losing state or funds.
- **Contribution and Withdrawal Flexibility**: Contributors can withdraw their funds if the campaign is canceled or the goal is not yet reached.
- **Automatic and Manual Payout Options**: Funds are transferred to the owner either automatically when the goal is reached or manually through a function call, with plans for future automation via smart contract logic.
- **Event Logging**: Comprehensive event logging for contributions, withdrawals, goal achievement, and campaign cancellation.

## Contract Specifications

### FundraiserUpgradeable

- **Initialization and Ownership**: Initialized with a funding goal; ownership is set through OpenZeppelin's `OwnableUpgradeable`.
- **Contribute Function**: Allows contributions unless the campaign is canceled or the goal is reached.
- **Withdrawal and Cancellation**: Contributors can withdraw before the goal is reached or if the campaign is canceled; the owner can cancel the campaign.
- **Payout Mechanics**: Currently, a placeholder function exists for future automated core purchases via cross-chain messaging (XCM) mechanisms.

### Fundraiser

- **Contract Initialization**: Similar functionality to `FundraiserUpgradeable` but with non-upgradeable properties.
- **Ownership and Security**: Utilizes OpenZeppelin’s non-upgradeable `Ownable` for managing ownership and security.
- **Contribution Tracking**: Manages contributions and checks if the fundraising goal has been met.
- **Payout and Withdrawal**: Allows payout to the owner and withdrawals by contributors under conditions similar to the upgradeable version.

### Factory Contract

- **Functionality**: Allows the creation of new `Fundraiser` contracts, transferring ownership to the creator, and tracking of all deployed fundraisers.

## Technical Implementation

### Initialization and Upgradability

- **Upgradeable Contract**: `FundraiserUpgradeable` uses OpenZeppelin’s upgradeable contract frameworks to allow future enhancements without losing existing data or funds.
- **Standard Contract**: `Fundraiser` provides a simpler, non-upgradeable alternative for use cases where upgradeability is not a concern.

### Future Enhancements

- **Automated Purchases**: Future versions of the `FundraiserUpgradeable` will automate the purchasing process upon reaching fundraising goals using advanced blockchain functionalities like Moonbeam’s XCM transact precompile.

### XCM Compatibility

- **Cross-Chain Messaging (XCM)**: 

TODO: Add more documentation on making the crowdfunding contract compatible with XCM, facilitating interactions across different blockchain networks.
