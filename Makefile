-include .env

help:
	@echo "Usage:"
	@echo "  make deploy-local"
	@echo "  make deploy-alphajores"

all: clean remove install update build

# Clean the repo
clean :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Update Dependencies
update:; forge update

# Compile contracts
build:
	@echo "Building contracts..."
	@forge build

test :; forge test
snapshot :; forge snapshot
format :; forge fmt
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

deploy-local:
	@echo "Deploying contracts locally..."
	@forge script script/DeployEuroPool.s.sol \
	--rpc-url $(ANVIL_RPC_URL) \
	--private-key $(ANVIL_DEFAULT_PRIVATE_KEY) \
	--broadcast \
	-vvvv

deploy-alfajores:
	@echo "Deploying contracts to Alfajores..."
	@forge script script/DeployEuroPool.s.sol \
	--rpc-url $(ALFAJORES_RPC_URL) \
	--private-key $(ALFAJORES_PRIVATE_KEY) \
	--broadcast \
	-vvvv
# --verify --ethscan-api-key $(ALFAJORES_API_KEY)
