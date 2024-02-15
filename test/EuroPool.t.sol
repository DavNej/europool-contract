// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {DeployEuroPool} from "../script/DeployEuroPool.s.sol";
import {MockERC20} from "./mock/MockERC20.sol";

import {EuroPool} from "../src/EuroPool.sol";

// Simple test suite that tests the EuroPool contract. This suite does not include gas price for simplicity reasons

contract EuroPoolTest is Test {
    IERC20 token;
    EuroPool euroPool;

    address euroPoolOwner;
    address tokenDeployer;

    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    address CHARLES = makeAddr("charles");

    function setUp() external {
        DeployEuroPool deployEuroPool = new DeployEuroPool();
        euroPool = deployEuroPool.run();
        token = IERC20(deployEuroPool.tokenAddress());
        tokenDeployer = msg.sender;
        euroPoolOwner = euroPool.owner();

        vm.startPrank(tokenDeployer);
        token.transfer(euroPoolOwner, 10000 ether);
        token.transfer(ALICE, 100 ether);
        token.transfer(BOB, 100 ether);
        token.transfer(CHARLES, 100 ether);
        vm.stopPrank();

        console.log("tokenDeployer balance", token.balanceOf(msg.sender));
        console.log("ALICE balance", token.balanceOf(ALICE));
        console.log("BOB balance", token.balanceOf(BOB));
        console.log("CHARLES balance", token.balanceOf(CHARLES));
    }

    function testOwnerIsThisContract() public {
        assertEq(euroPool.owner(), address(this));
    }

    function testOwnerCanFundRewardPool() public {
        vm.startPrank(euroPoolOwner);
        token.approve(address(euroPool), 100 ether);
        euroPool.fundRewardPool(100 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(address(euroPool)), 100 ether);
    }

    function testOnlyOwnerCanFundRewardPool() public {
        vm.startPrank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ALICE));
        euroPool.fundRewardPool(1 ether);
        vm.stopPrank();
    }
}
