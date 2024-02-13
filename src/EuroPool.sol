// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error EuroPool__TransferFailed();
error EuroPool__NeedsMoreThanZero();

contract Staking is Ownable {
    IERC20 public s_stakingToken;

    // We assume the contract generate 100 tokens per second to be distributed among the stakers
    // The more users stake, the less for everyone who is staking
    uint256 public constant REWARD_RATE = 100;

    uint256 private s_totalStaked;

    mapping(address => uint256) private s_balances;
    mapping(address => uint256) private s_rewards;

    uint256 private s_rewardPerStakedToken;
    uint256 private s_lastUpdateTime;

    mapping(address => uint256) private s_userPaidRewardPerStakedToken;

    /**
     * Events
     */
    event Staked(address indexed user, uint256 indexed amount);
    event StakeWithdrawn(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);
    event RewardPoolFunded(uint256 indexed amount);

    constructor(address initialOwner, address stakingToken) Ownable(initialOwner) {
        // We assume this contract generates rewards in the same token as the one that is staked.
        // This implies that the amout of stakingToken owned by the contract should always be greater than the reward owed to stakers.
        s_stakingToken = IERC20(stakingToken);
    }

    /**
     * Modifier Functions
     */
    modifier updateReward(address account) {
        s_rewardPerStakedToken = rewardPerStakedToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userPaidRewardPerStakedToken[account] = s_rewardPerStakedToken;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert EuroPool__NeedsMoreThanZero();
        }
        _;
    }

    /**
     * Utility Functions
     */

    /**
     * @notice Calculate how much reward a token generates. Based on how long it's been staked and during which "snapshot" period
     */
    function rewardPerStakedToken() public view returns (uint256) {
        if (s_totalStaked == 0) {
            return s_rewardPerStakedToken;
        }
        return s_rewardPerStakedToken + (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalStaked);
    }

    /**
     * @notice How much reward a user has earned
     */
    function earned(address account) public view returns (uint256) {
        return ((s_balances[account] * (rewardPerStakedToken() - s_userPaidRewardPerStakedToken[account])) / 1e18)
            + s_rewards[account];
    }

    /**
     * Action Functions
     */

    /**
     * @notice Deposit tokens to stake
     * @param amount Number of tokens to stake
     */
    function stake(uint256 amount) external moreThanZero(amount) updateReward(msg.sender) {
        s_totalStaked += amount;
        s_balances[msg.sender] += amount;

        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert EuroPool__TransferFailed();
        }

        emit Staked(msg.sender, amount);
    }

    /**
     * @notice Withdraw staked tokens
     * @param amount Number of tokens to withdraw
     */
    function withdraw(uint256 amount) external updateReward(msg.sender) {
        s_totalStaked -= amount;
        s_balances[msg.sender] -= amount;

        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert EuroPool__TransferFailed();
        }

        emit StakeWithdrawn(msg.sender, amount);
    }

    /**
     * @notice Owner of the contract add funds to rewards to the pool
     */
    function fundRewardPool(uint256 amount) external onlyOwner {
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert EuroPool__TransferFailed();
        }
        emit RewardPoolFunded(amount);
    }

    /**
     * Getter Functions
     */
    function getStaked(address account) public view returns (uint256) {
        return s_balances[account];
    }

    function getTotalStaked() public view returns (uint256) {
        return s_totalStaked;
    }

    function getContractTokenBalance() public view returns (uint256) {
        return s_stakingToken.balanceOf(address(this));
    }
}
