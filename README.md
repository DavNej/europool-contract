## EuropPool contract - Staking Contract

EuroPool is a simple staking contract. This contract enables users to perform the following actions :

* [x] Deposit cEUR and earn rewards based on their deposit
* [x] Withdraw their deposits and earned rewards at any time
* [x] Withdraw their initial deposit and their proportionate share of rewards based on the timing of their deposit
* [x] At any time, the contract's deployer (only) can periodically add funds to the rewards pool via the `funRewardsPool` function

* [x] Unit tests are included to verify the correctness of the contract

* Contract inspired by: [Staking Rewards](https://solidity-by-example.org/defi/staking-rewards/)
* Assumptions made:
  + The contract generates 100 wei per second to be distributed among the stakers. The more token staked, the less reward per token
  + Generated rewards are in the same token as the token staked. Hence, the amount of token owned by the contract should always be greater than the total staked + total rewards owed to stakers.

Technologies used:

* Foundry
* Solidity

## Contract Deployment and Verification

* [x] Includes a deployment script to deploy 'EuroPool' locally and to the Celo Alfajores testnet
* [x] Address of the deployed contract on Celo Alfajores: `0xb45Fa036d3E90c9900397D1F0EcaBE65A6967C93`
* [x] Address of the Deployer of the contract on Celo Alfajores: `0x18538e68760D6f6062691f65e7255B737bBD9726`

## Usage

### Setup

```shell
$ make all
```

### Deploy

#### Locally

```shell
$ make anvil
```

then 

```shell
$ make local-deploy
```

#### Alfajores

```shell
$ make alfajores-deploy
```
