// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {MockERC20} from "../test/MockERC20.sol";
import {EuroPool} from "../src/EuroPool.sol";

contract DeployEuroPool is Script {
    address public tokenAddress;

    function run() external returns (EuroPool) {
        HelperConfig helperConfig = new HelperConfig();
        tokenAddress = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        EuroPool euroPool = new EuroPool(msg.sender, tokenAddress);
        vm.stopBroadcast();
        return euroPool;
    }
}
