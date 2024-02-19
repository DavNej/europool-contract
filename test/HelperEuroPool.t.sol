// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EuroPool} from "../src/EuroPool.sol";

abstract contract HelperEuroPool is Test {
    IERC20 s_token;
    EuroPool s_euroPool;
    address s_tokenDeployer;

    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    address CHARLES = makeAddr("charles");

    uint256 constant INITIAL_OWNER_BALANCE = 10000 ether;
    uint256 constant INITIAL_ALICE_BALANCE = 100 ether;
    uint256 constant INITIAL_BOB_BALANCE = 100 ether;
    uint256 constant INITIAL_CHARLES_BALANCE = 100 ether;

    uint256 constant INITIAL_REWARD_POOL_SIZE = 500 ether;

    event Staked(address indexed user, uint256 indexed amount);
    event StakeWithdrawn(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);
    event RewardPoolFunded(uint256 indexed amount);

    function fundUsersWithToken() internal {
        vm.startPrank(s_tokenDeployer);
        s_token.transfer(s_euroPool.owner(), INITIAL_OWNER_BALANCE);
        s_token.transfer(ALICE, INITIAL_ALICE_BALANCE);
        s_token.transfer(BOB, INITIAL_BOB_BALANCE);
        s_token.transfer(CHARLES, INITIAL_CHARLES_BALANCE);
        vm.stopPrank();

        assertEq(s_token.balanceOf(s_euroPool.owner()), INITIAL_OWNER_BALANCE);
        assertEq(s_token.balanceOf(ALICE), INITIAL_ALICE_BALANCE);
        assertEq(s_token.balanceOf(BOB), INITIAL_BOB_BALANCE);
        assertEq(s_token.balanceOf(CHARLES), INITIAL_CHARLES_BALANCE);
    }

    function fundRewardPool() public {
        vm.startPrank(s_euroPool.owner());
        s_token.approve(address(s_euroPool), INITIAL_REWARD_POOL_SIZE);
        s_euroPool.fundRewardPool(INITIAL_REWARD_POOL_SIZE);
        vm.stopPrank();

        assertEq(s_token.balanceOf(address(s_euroPool)), INITIAL_REWARD_POOL_SIZE);
        assertEq(s_token.balanceOf(s_euroPool.owner()), INITIAL_OWNER_BALANCE - INITIAL_REWARD_POOL_SIZE);
    }

    function stakeFor(address user, uint256 amount) public {
        vm.startPrank(user);
        s_token.approve(address(s_euroPool), amount);
        s_euroPool.stake(amount);
        vm.stopPrank();
    }

    function withdrawFor(address user, uint256 amount) public {
        vm.startPrank(user);
        s_token.approve(address(s_euroPool), amount);
        s_euroPool.withdraw(amount);
        vm.stopPrank();
    }
}
