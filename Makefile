-include .env

help:
	@echo "Usage:"
	@echo "  make deploy-local"
	@echo "  make deploy-alphajores"

all: clean remove install update build test

# Clean the repo
clean :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install Dependencies
install :; forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install OpenZeppelin/openzeppelin-contracts@v5.0.1 --no-commit

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

local-deploy:
	@echo "Deploying contracts locally..."
	@forge script script/DeployEuroPool.s.sol \
	--rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_DEFAULT_PRIVATE_KEY) \
	--broadcast \
	-vvvv

alfajores-deploy:
	@echo "Deploying contracts to Alfajores..."
	@forge script script/DeployEuroPool.s.sol \
	--rpc-url $(ALFAJORES_RPC_URL) --private-key $(ALFAJORES_DEPLOYER_PRIVATE_KEY) \
	--broadcast \
	-vvvv

alfajores-fund-europool:
	@echo "Funding EuroPool reward pool with tokens..."
	@forge script script/FundEuroPool.s.sol \
	--rpc-url $(ALFAJORES_RPC_URL) --private-key $(ALFAJORES_DEPLOYER_PRIVATE_KEY) \
	--broadcast \
	-vvvv

alfajores-ceur-balance-of-deployer:
	@echo "Get token balance of deployer $(ALFAJORES_DEPLOYER_ADDRESS)..."
	@cast call \
	--rpc-url $(ALFAJORES_RPC_URL) \
	$(ALFAJORES_CEUR_ADDRESS) \
	"balanceOf(address)" $(ALFAJORES_DEPLOYER_ADDRESS) \
	-- -vvvv

alfajores-ceur-balance-of-europool:
	@echo "Get token balance of europool $(ALFAJORES_EUROPOOL_ADDRESS)..."
	@cast call \
	--rpc-url $(ALFAJORES_RPC_URL) \
	$(ALFAJORES_CEUR_ADDRESS) \
	"balanceOf(address)" $(ALFAJORES_EUROPOOL_ADDRESS) \
	-- -vvvv
