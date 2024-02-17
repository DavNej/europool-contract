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

    constructor() {
        if (block.chainid == ALFAJORES_CHAIN_ID) {
            activeNetworkConfig = getAlfajoresCeloConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilLocalConfig();
        }
    }

    function getAlfajoresCeloConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory alfajoresConfig = NetworkConfig({tokenAddress: 0x10c892A6EC43a53E45D0B916B4b7D383B1b78C0F});
        return alfajoresConfig;
    }

    function getOrCreateAnvilLocalConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.tokenAddress != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockERC20 token = new MockERC20();

        vm.stopBroadcast();

        NetworkConfig memory anvilLocalConfig = NetworkConfig({tokenAddress: address(token)});
        return anvilLocalConfig;
    }
}
