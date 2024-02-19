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

    /**
     * Withdrawal Functionality Tests
     */

    // Verifies that a user can withdraw their staked tokens and the correct amount is returned.
    function testSuccessfulWithdrawal() public {
        uint256 stakeAmount = 50 ether;
        uint256 initialBalanceAlice = s_token.balanceOf(ALICE);
        uint256 initialTotalStaked = s_euroPool.getTotalStaked();

        // Alice stakes tokens
        stakeFor(ALICE, stakeAmount);
        assertEq(s_euroPool.getStakedBalanceOf(ALICE), stakeAmount);

        // Alice withdraws the staked tokens
        vm.startPrank(ALICE);
        vm.expectEmit(true, true, true, true);
        emit StakeWithdrawn(ALICE, stakeAmount);
        s_euroPool.withdraw(stakeAmount);
        vm.stopPrank();

        assertEq(s_token.balanceOf(ALICE), initialBalanceAlice, "Alice's balance should be restored after withdrawal");
        assertEq(s_euroPool.getTotalStaked(), initialTotalStaked, "Total staked should be unchanged");
    }

    // Checks if withdrawing tokens correctly updates the user's balance and the total staked amount.
    function testWithdrawUpdatesUserBalanceAndTotalStaked() public {
        uint256 stakeAmountAlice = 30 ether;
        uint256 stakeAmountBob = 20 ether;

        // Initial checks
        uint256 initialTotalStaked = s_euroPool.getTotalStaked();

        uint256 initialStakedAlice = s_euroPool.getStakedBalanceOf(ALICE);
        uint256 initialStakedBob = s_euroPool.getStakedBalanceOf(BOB);

        uint256 initialBalanceAlice = s_token.balanceOf(ALICE);
        uint256 initialBalanceBob = s_token.balanceOf(BOB);

        // Stake tokens
        stakeFor(ALICE, stakeAmountAlice);
        stakeFor(BOB, stakeAmountBob);
        assertEq(s_euroPool.getStakedBalanceOf(ALICE), initialStakedAlice + stakeAmountAlice);
        assertEq(s_euroPool.getStakedBalanceOf(BOB), initialStakedBob + stakeAmountBob);
        assertEq(s_euroPool.getTotalStaked(), initialTotalStaked + stakeAmountAlice + stakeAmountBob);

        // Withdraw staked tokens
        vm.startPrank(ALICE);
        s_euroPool.withdraw(stakeAmountAlice);
        vm.stopPrank();

        vm.startPrank(BOB);
        s_euroPool.withdraw(stakeAmountBob);
        vm.stopPrank();

        // Verifying balances
        assertEq(s_euroPool.getStakedBalanceOf(ALICE), initialStakedAlice);
        assertEq(s_euroPool.getStakedBalanceOf(BOB), initialStakedBob);
        assertEq(s_euroPool.getTotalStaked(), initialTotalStaked);

        assertEq(s_token.balanceOf(ALICE), initialBalanceAlice, "Alice's balance should be restored after withdrawal");
        assertEq(s_token.balanceOf(BOB), initialBalanceBob, "Bob's balance should be restored after withdrawal");

        assertEq(s_euroPool.getTotalStaked(), initialTotalStaked, "Total staked should be unchanged");
    }

    // Tests that trying to withdraw more than the staked amount reverts.
    function testWithdrawMoreThanStakedReverts() public {
        uint256 stakeAmount = 50 ether;
        uint256 withdrawAmount = stakeAmount + 10 ether;

        stakeFor(ALICE, stakeAmount);

        // Alice attempts to withdraw more than she has staked
        vm.startPrank(ALICE);
        vm.expectRevert();
        s_euroPool.withdraw(withdrawAmount);
        vm.stopPrank();
    }

    /**
     * Reward Functionality Tests
     */

    // Tests that a user can claim their rewards successfully.
    function testSuccessfulRewardClaim() public {
        uint256 initialBalanceAlice = s_token.balanceOf(ALICE);
        uint256 stakeAmount = 50 ether;
        stakeFor(ALICE, stakeAmount);

        uint256 timeElapsed = 1 hours;
        vm.warp(block.timestamp + timeElapsed);

        uint256 expectedRewards = s_euroPool.getRewardsOf(ALICE);

        vm.prank(ALICE);
        vm.expectEmit(true, true, true, true);
        emit RewardsClaimed(ALICE, expectedRewards);
        s_euroPool.claimReward();

        assertEq(
            s_token.balanceOf(ALICE),
            initialBalanceAlice - stakeAmount + expectedRewards,
            "Alice's balance did not increase by the expected rewards amount."
        );

        // Verify Alice's rewards are reset to zero
        assertEq(s_euroPool.getRewardsOf(ALICE), 0, "Alice's rewards were not reset after claiming.");
    }

    // Checks that attempting to claim rewards when there are none reverts appropriately.
    function testClaimZeroRewardsReverts() public {
        vm.startPrank(ALICE);
        vm.expectRevert();
        s_euroPool.claimReward();
        vm.stopPrank();
    }

    /**
     * Owner Actions Tests
     */

    // Tests that the contract owner can fund the reward pool successfully.
    function testOwnerCanFundRewardPool() public {
        uint256 amountToFund = 100 ether;

        vm.startPrank(s_euroPool.owner());
        s_token.approve(address(s_euroPool), amountToFund);

        vm.expectEmit(true, true, true, true);
        emit RewardPoolFunded(amountToFund);

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

    // Tests that attempting to fund more than the owner's balance reverts.
    function testFundMoreThanBalanceReverts() public {
        uint256 excessAmount = s_token.balanceOf(s_euroPool.owner()) + 1 ether;
        vm.startPrank(s_euroPool.owner());
        s_token.approve(address(s_euroPool), excessAmount);
        vm.expectRevert();
        s_euroPool.fundRewardPool(excessAmount);
        vm.stopPrank();
    }

    /**
     * Utility and Modifier Tests
     */

    // Tests the rewardPerStakedToken function for accuracy in various scenarios.
    function testRewardPerStakedTokenCalculation() public {
        uint256 stakeAmount = 55 ether;
        uint256 rewardRate = s_euroPool.getRewardRate();
        uint256 timeElapsed = 1 hours;

        stakeFor(ALICE, stakeAmount);
        vm.warp(block.timestamp + timeElapsed);

        uint256 actualRewardPerToken = s_euroPool.rewardPerStakedToken();
        uint256 expectedRewardPerToken = (timeElapsed * rewardRate * 1e18) / (stakeAmount);

        assertEq(actualRewardPerToken, expectedRewardPerToken, "Reward per staked token calculation mismatch.");
    }

    // Verifies that the earned function accurately calculates the amount of rewards earned by a user.
    function testEarnedCalculation() public {
        uint256 stakeAmountAlice = 50 ether;
        uint256 stakeAmountBob = 30 ether;
        uint256 stakeAmountCharles = 20 ether;

        // Alice stakes tokens
        stakeFor(ALICE, stakeAmountAlice);
        uint256 timeElapsedForAlice = 100 seconds;
        vm.warp(block.timestamp + timeElapsedForAlice);

        uint256 expectedRewardsRateFirst = s_euroPool.rewardPerStakedToken();

        // Bob stakes tokens after Alice
        stakeFor(BOB, stakeAmountBob);
        uint256 timeElapsedForBob = 100 seconds;
        vm.warp(block.timestamp + timeElapsedForBob);

        uint256 expectedRewardsRateSecond = s_euroPool.rewardPerStakedToken();

        // Charles stakes tokens after Bob
        stakeFor(CHARLES, stakeAmountCharles);
        uint256 timeElapsedForCharles = 100 seconds;
        vm.warp(block.timestamp + timeElapsedForCharles);

        uint256 expectedRewardsRateThird = s_euroPool.rewardPerStakedToken();

        uint256 expectedRewardsAlice = (
            (expectedRewardsRateFirst) + (expectedRewardsRateSecond - expectedRewardsRateFirst)
                + (expectedRewardsRateThird - expectedRewardsRateSecond)
        ) * stakeAmountAlice / 1e18;
        assertEq(s_euroPool.earned(ALICE), expectedRewardsAlice, "Alice's earned rewards calculation mismatch");

        uint256 expectedRewardsBob = (
            (expectedRewardsRateSecond - expectedRewardsRateFirst)
                + (expectedRewardsRateThird - expectedRewardsRateSecond)
        ) * stakeAmountBob / 1e18;
        assertEq(s_euroPool.earned(BOB), expectedRewardsBob, "Bob's earned rewards calculation mismatch");

        uint256 expectedRewardsCharles =
            (expectedRewardsRateThird - expectedRewardsRateSecond) * stakeAmountCharles / 1e18;
        assertEq(s_euroPool.earned(CHARLES), expectedRewardsCharles, "Charles's earned rewards calculation mismatch");
    }

    // Specifically tests the effects of the updateReward and moreThanZero modifiers on staking and withdrawing functionality
    function testModifiersEffectOnStakingAndWithdrawing() public {
        uint256 stakeAmount = 50 ether;

        // Test updateReward modifier by checking rewards before and after staking
        uint256 initialRewards = s_euroPool.getRewardsOf(ALICE);
        stakeFor(ALICE, stakeAmount);
        vm.warp(block.timestamp + 100 seconds);
        assertTrue(s_euroPool.getRewardsOf(ALICE) > initialRewards, "Rewards not updated after staking");

        // Test moreThanZero modifier by attempting to stake 0 and expecting a revert
        vm.startPrank(ALICE);
        s_token.approve(address(s_euroPool), 0);
        vm.expectRevert(EuroPool__NeedsMoreThanZero.selector);
        s_euroPool.stake(0);
        vm.stopPrank();

        // Test moreThanZero modifier by attempting to withdraw 0 and expecting a revert
        vm.startPrank(ALICE);
        vm.expectRevert(EuroPool__NeedsMoreThanZero.selector);
        s_euroPool.withdraw(0);
        vm.stopPrank();

        // Test updateReward modifier by checking rewards before and after withdrawing
        uint256 withdrawAmount = 20 ether;
        initialRewards = s_euroPool.getRewardsOf(ALICE);
        vm.warp(block.timestamp + 100 seconds);
        withdrawFor(ALICE, withdrawAmount);
        assertTrue(s_euroPool.getRewardsOf(ALICE) > initialRewards, "Rewards not updated after withdrawal");
    }

    /**
     * Getters Tests
     */

    // Tests the getStakingToken function returns the address of the staking s_token.
    function testGetStakingToken() public {
        assertEq(s_euroPool.getStakingToken(), address(s_token));
    }

    // Tests the getRewardRate function returns the reward rate of the contract.
    function testGetRewardRate() public {
        assertEq(s_euroPool.getRewardRate(), 100);
    }

    // Tests the getTotalStaked function returns the total amount of tokens staked in the contract.
    function testGetTotalStaked() public {
        uint256 stakeAmount = 50 ether;
        stakeFor(ALICE, stakeAmount);
        assertEq(s_euroPool.getTotalStaked(), stakeAmount);
    }

    // Tests the getRewardPoolBalance function returns the size of the reward pool.
    function testGetRewardPoolBalance() public {
        uint256 stakeAmount = 50 ether;
        stakeFor(ALICE, stakeAmount);
        assertEq(s_euroPool.getRewardPoolBalance(), INITIAL_REWARD_POOL_SIZE);
    }

    // Tests the getStakedBalanceOf function returns the correct balance staked by a user.
    function testGetStakedBalanceOf() public {
        uint256 stakeAmount = 50 ether;
        stakeFor(ALICE, stakeAmount);
        assertEq(s_euroPool.getStakedBalanceOf(ALICE), stakeAmount);
    }

    // Tests the getRewardsOf function returns the correct reward owned by a user.
    function testGetRewardsOf() public {
        uint256 stakeAmount = 50 ether;
        stakeFor(ALICE, stakeAmount);

        vm.warp(block.timestamp + 100 seconds);

        uint256 expectedRewardsRate = s_euroPool.rewardPerStakedToken();
        uint256 expectedRewards = expectedRewardsRate * stakeAmount / 1e18;

        assertEq(s_euroPool.getRewardsOf(ALICE), expectedRewards);
    }
}
