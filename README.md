# Extension contracts to the Coretieme chain

## Contracts

### Crowdfunding Purchase
This Solidity smart contract is designed for organizing multiple fundraising campaigns simultaneously, leveraging OpenZeppelin libraries for security and efficiency. Each campaign can set a specific funding target, and individuals can contribute funds towards reaching this goal. The smart contract features a `purchase_core()` function that activates once the target amount is met; however, if this function fails or reverts for any reason, contributors have the option to withdraw their donations. Additionally, the creator of each fundraising campaign retains the authority to cancel the campaign at any point, enabling the return of contributed funds to their respective donors. This setup ensures transparency, security, and flexibility in fundraising activities on the Ethereum blockchain.


**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Forge remappings

```
forge remappings > remappings.txt
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy
copy .env.local.example to env.local

```shell
./deploy.sh
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
