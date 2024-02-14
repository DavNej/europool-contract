// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {EuroPool} from "../src/EuroPool.sol";

import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployEuroPool is Script {
    function run() external returns (EuroPool) {
        HelperConfig helperConfig = new HelperConfig();
        address cEUR = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        EuroPool euroPool = new EuroPool(msg.sender, cEUR);
        vm.stopBroadcast();
        return euroPool;
    }
}
