// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MockERC20} from "../test/MockERC20.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address tokenAddress;
    }

    NetworkConfig public activeNetworkConfig;

    uint256 public ALFAJORES_CHAIN_ID = 44787;
    uint256 public SEPOLIA_CHAIN_ID = 11155111;
    uint256 public MUMBAI_CHAIN_ID = 80001;

    constructor() {
        if (block.chainid == ALFAJORES_CHAIN_ID) {
            activeNetworkConfig = getCeloAlfajoresConfig();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getEthereumSepoliaConfig();
        } else if (block.chainid == MUMBAI_CHAIN_ID) {
            activeNetworkConfig = getPolygonMumbaiConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilLocalConfig();
        }
    }

    function getCeloAlfajoresConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({tokenAddress: 0x10c892A6EC43a53E45D0B916B4b7D383B1b78C0F}); // cEUR
    }

    function getPolygonMumbaiConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({tokenAddress: 0x6D8873f56a56f0Af376091beddDD149f3592e854}); // DAI
    }

    function getEthereumSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({tokenAddress: 0x523C8591Fbe215B5aF0bEad65e65dF783A37BCBC}); // USDT
    }

    function getOrCreateAnvilLocalConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.tokenAddress != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockERC20 token = new MockERC20();
        vm.stopBroadcast();

        return NetworkConfig({tokenAddress: address(token)});
    }
}
