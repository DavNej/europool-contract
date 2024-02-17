// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DeployEuroPool} from "../script/DeployEuroPool.s.sol";
import {HelperEuroPool} from "./HelperEuroPool.t.sol";
import {MockERC20} from "./MockERC20.sol";

// Simple test suite that tests the EuroPool contract. This suite does not include gas price for simplicity reasons

contract EuroPoolTest is HelperEuroPool {
    function setUp() external {
        DeployEuroPool deployEuroPool = new DeployEuroPool();
        s_euroPool = deployEuroPool.run();
        s_token = IERC20(deployEuroPool.tokenAddress());
        s_tokenDeployer = msg.sender;

        fundUsersWithToken();
        fundRewardPool();
    }

    function testOwnerIsThisContract() public {
        assertEq(s_euroPool.owner(), address(this));
    }

    function testOwnerCanFundRewardPool() public {
        uint256 amountToFund = 100 ether;

        vm.startPrank(s_euroPool.owner());
        s_token.approve(address(s_euroPool), amountToFund);
        s_euroPool.fundRewardPool(amountToFund);
        vm.stopPrank();

        assertEq(s_token.balanceOf(address(s_euroPool)), INITIAL_REWARD_POOL_SIZE + amountToFund);
    }

    // Ensures that only the contract owner can fund the reward pool, and others are reverted.
    function testOnlyOwnerCanFundRewardPool() public {
        vm.startPrank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ALICE));
        s_euroPool.fundRewardPool(1 ether);
        vm.stopPrank();
    }

