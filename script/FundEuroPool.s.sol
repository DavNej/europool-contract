// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {EuroPool} from "../src/EuroPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FundEuroPool is Script {
    uint256 FUNDING_AMOUNT = 5 ether;
    address euroPoolAddress = 0xb45Fa036d3E90c9900397D1F0EcaBE65A6967C93;
    address tokenAddress;

    function fundEuroPool() public {
        vm.startBroadcast();
        IERC20(tokenAddress).approve(euroPoolAddress, FUNDING_AMOUNT);
        EuroPool(euroPoolAddress).fundRewardPool(FUNDING_AMOUNT);
        console.log("Funded EuroPool with %s", FUNDING_AMOUNT);
        vm.stopBroadcast();
    }

    function run() public {
        HelperConfig helperConfig = new HelperConfig();
        tokenAddress = helperConfig.activeNetworkConfig();

        require(block.chainid == helperConfig.ALFAJORES_CHAIN_ID(), "Chain must be Alfajores");

        fundEuroPool();
    }
}
