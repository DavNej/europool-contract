-include .env

.PHONY: deploy fund-europool token-balance-of-deployer token-balance-of-europool

help:
	@echo "Usage:"
	@echo '  make deploy ARGS="--network sepolia"'
	@echo '  make fund-europool ARGS="--network mumbai"'
	@echo '  make token-balance-of-deployer ARGS="--network sepolia"'
	@echo '  make token-balance-of-europool'
	@echo ""
	@echo "  Supported networks: sepolia, mumbai, alfajores, local"

all: clean remove install update build
clean :; forge clean
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"
install :; forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install OpenZeppelin/openzeppelin-contracts@v5.0.1 --no-commit
update:; forge update
build:
	@echo "Building contracts..."
	@forge build

## Launch local chain
anvil:
	@anvil --chain-id 1337 -m 'test test test test test test test test test test test junk'


## Deploy rules
NETWORK_NAME := ""
NETWORK_ARGS := ""
DEPLOY_ARGS := "--keystore devDeployer"
VERIFY_ARGS := ""
RPC_URL := ""
TOKEN_ADDRESS := ""
EUROPOOL_ADDRESS := ""

ifeq ($(findstring --network alfajores,$(ARGS)),--network alfajores)
	NETWORK_NAME := Alfajores
	NETWORK_ARGS := --rpc-url $(ALFAJORES_RPC_URL)
	VERIFY_ARGS := "--verify --etherscan-api-key $(CELOSCAN_API_KEY)"

	RPC_URL := $(ALFAJORES_RPC_URL)
	TOKEN_ADDRESS := $(ALFAJORES_TOKEN_ADDRESS)
	EUROPOOL_ADDRESS := $(ALFAJORES_EUROPOOL_ADDRESS)
endif

ifeq ($(findstring --network mumbai,$(ARGS)),--network mumbai)
	NETWORK_NAME := "Mumbai"
	NETWORK_ARGS := --rpc-url $(MUMBAI_RPC_URL)
	VERIFY_ARGS := "--verify --etherscan-api-key $(POLYGONSCAN_API_KEY)"

	RPC_URL := $(MUMBAI_RPC_URL)
	TOKEN_ADDRESS := $(MUMBAI_TOKEN_ADDRESS)
	EUROPOOL_ADDRESS := $(MUMBAI_EUROPOOL_ADDRESS)
endif

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_NAME := "Sepolia"
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL)
	VERIFY_ARGS := "--verify --etherscan-api-key $(ETHERSCAN_API_KEY)"

	RPC_URL := $(SEPOLIA_RPC_URL)
	TOKEN_ADDRESS := $(SEPOLIA_TOKEN_ADDRESS)
	EUROPOOL_ADDRESS := $(SEPOLIA_EUROPOOL_ADDRESS)
endif

ifeq ($(strip $(ARGS)),)
	NETWORK_NAME := "Anvil"
	NETWORK_ARGS := "--rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_DEPLOYER_PRIVATE_KEY)"
	VERIFY_ARGS := ""
	DEPLOY_ARGS := ""
endif


deploy:
	@echo "Deploying contracts to $(NETWORK_NAME)..."
	@forge script script/DeployEuroPool.s.sol $(NETWORK_ARGS) --broadcast $(VERIFY_ARGS) $(DEPLOY_ARGS) -vvvv

## Fund EuroPool rules
fund-europool:
	@echo "Funding $(NETWORK_NAME) EuroPool reward pool with tokens..."
	@forge script script/FundEuroPool.s.sol $(NETWORK_ARGS) --broadcast -vvvv

## Balance rules
token-balance-of-deployer:
	@echo $(ARGS)
	@echo "Get token balance of deployer $(DEPLOYER_ADDRESS) on $(NETWORK_NAME)..."
	@cast call --rpc-url $(RPC_URL) $(TOKEN_ADDRESS) "balanceOf(address)" $(DEPLOYER_ADDRESS) \
	-- -vvvv

token-balance-of-europool:
	@echo "Get token balance of europool $(EUROPOOL_ADDRESS) on $(NETWORK_NAME)..."
	@cast call --rpc-url $(RPC_URL) $(TOKEN_ADDRESS) "balanceOf(address)" $(EUROPOOL_ADDRESS) \
	-- -vvvv
