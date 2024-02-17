// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DeployEuroPool} from "../script/DeployEuroPool.s.sol";
import {HelperEuroPool} from "./HelperEuroPool.t.sol";
import {MockERC20} from "./MockERC20.sol";
import {EuroPool__NeedsMoreThanZero} from "../src/EuroPool.sol";

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

    /**
     * Staking Functionality Tests
     */

    // Tests that a user can successfully stake tokens and the contract state updates accordingly.
    function testSuccessfulStake() public {
        uint256 initialTotalStaked = s_euroPool.getTotalStaked();
        uint256 initialContractBalance = s_token.balanceOf(address(s_euroPool));

        uint256 initialBalanceAlice = s_token.balanceOf(ALICE);
        uint256 stakeAmountAlice = 50 ether;

        vm.startPrank(ALICE);
        s_token.approve(address(s_euroPool), stakeAmountAlice);
        vm.expectEmit(true, true, true, true);
        emit Staked(ALICE, stakeAmountAlice);
        s_euroPool.stake(stakeAmountAlice);
        vm.stopPrank();

        // Check new balances
        assertEq(s_euroPool.getTotalStaked(), initialTotalStaked + stakeAmountAlice);
        assertEq(s_token.balanceOf(address(s_euroPool)), initialContractBalance + stakeAmountAlice);
        assertEq(s_token.balanceOf(ALICE), initialBalanceAlice - stakeAmountAlice);
    }

    // Checks if staking tokens correctly updates the user's balance and the total staked amount in the contract.
    function testStakeUpdatesUserBalanceAndTotalStaked() public {
        uint256 stakeAmountAlice = 30 ether;
        uint256 stakeAmountBob = 20 ether;

        // Initial checks
        uint256 initialTotalStaked = s_euroPool.getTotalStaked();
        uint256 initialStakedAlice = s_euroPool.getStakedBalanceOf(ALICE);
        uint256 initialStakedBob = s_euroPool.getStakedBalanceOf(BOB);

        // Stake tokens
        stakeFor(ALICE, stakeAmountAlice);
        stakeFor(BOB, stakeAmountBob);

        // Verifying Alice's staked balance
        uint256 finalStakedAlice = s_euroPool.getStakedBalanceOf(ALICE);
        assertEq(finalStakedAlice, initialStakedAlice + stakeAmountAlice);

        // Verifying Bob's staked balance
        uint256 finalStakedBob = s_euroPool.getStakedBalanceOf(BOB);
        assertEq(finalStakedBob, initialStakedBob + stakeAmountBob);

        // Verifying total staked in the contract
        uint256 finalTotalStaked = s_euroPool.getTotalStaked();
        assertEq(finalTotalStaked, initialTotalStaked + stakeAmountAlice + stakeAmountBob);
    }

    // Ensures that staking with a zero amount reverts with the appropriate error.
    function testStakeWithZeroAmountReverts() public {
        vm.startPrank(ALICE);
        s_token.approve(address(s_euroPool), 0);
        vm.expectRevert(EuroPool__NeedsMoreThanZero.selector);
        s_euroPool.stake(0);
        vm.stopPrank();
    }

    // Tests that attempting to stake more than the user's balance reverts.
    function testStakeMoreThanBalanceReverts() public {
        uint256 excessAmount = s_token.balanceOf(ALICE) + 1 ether;
        vm.startPrank(ALICE);
        s_token.approve(address(s_euroPool), excessAmount);
        vm.expectRevert();
        s_euroPool.stake(excessAmount);
        vm.stopPrank();
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

