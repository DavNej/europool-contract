## EuropPool contract

EuroPool is a simple staking application. Deposit, wait, earn

## Usage

### Install

```shell
$ forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### Run local chain

```shell
$ anvil
```

### Run Tests

```shell
$ forge test
```

### Deploy

```shell
$ forge script script/DeployEuroPool.s.sol:DeployEuroPool --rpc-url <your_rpc_url> --private-key <your_private_key>
```
