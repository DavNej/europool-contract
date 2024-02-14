// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {DeployEuroPool} from "../script/DeployEuroPool.s.sol";
import {EuroPool} from "../src/EuroPool.sol";

contract EuroPoolTest is Test {
    EuroPool euroPool;

    function setUp() external {
        DeployEuroPool deployEuroPool = new DeployEuroPool();

        euroPool = deployEuroPool.run();
    }

    function testOwnerIsMsgSender() public {
        assertEq(euroPool.owner(), address(this));
    }
}
