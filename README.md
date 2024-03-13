## EuropPool contract - Staking Contract

EuroPool is a simple staking contract. This contract enables users to perform the following actions :

* [x] Deposit a given token and earn rewards based on their deposit
* [x] Withdraw their deposits and earned rewards at any time
* [x] Withdraw their initial deposit and their proportionate share of rewards based on the timing of their deposit
* [x] At any time, the contract's deployer (only) can add funds to the rewards pool via the `funRewardsPool` function

* [x] Unit tests are included to verify the correctness of the contract

* Contract inspired by: [Staking Rewards](https://solidity-by-example.org/defi/staking-rewards/)
* Assumptions made:
  + The contract generates 100 wei per second to be distributed among the stakers. The more token staked, the less reward per token
  + Generated rewards are in the same token as the token staked. Hence, the amount of token owned by the contract should always be greater than the total staked + total rewards owed to stakers.

Technologies used:

* Foundry
* Solidity

## Contract Deployment and Verification

* [x] Includes a deployment script to deploy 'EuroPool' locally and to Ethereum Sepolia, Polygon Mumbai and Celo Alfajores testnets
* [x] Address of the deployed contract and of the Deployer of the contract can be found in .env.example
* [x] Contract is verified on
  + [x] [Sepolia EtherScan](https://sepolia.etherscan.io/address/0x6f1a5f49e15c90fcdb54157029063548be2be220#code)
  + [x] [Mumbai PolygonScan](https://mumbai.polygonscan.com/address/0x6F1A5F49E15c90fcDb54157029063548Be2bE220#code)

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

then generate the deploy command:

```shell
$ make deploy-command
```

#### Mumbai

To generate the deploy command for Mumbai:

```shell
$ make deploy-command ARGS="--network mumbai"
```

Available networks are: Mumbai, Sepolia and Alfajores
