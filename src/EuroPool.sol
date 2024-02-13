// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    IERC20 public s_stakingToken;

    // We assume the contract generate 100 tokens per second to be distributed among the stakers
    // The more users stake, the less for everyone who is staking
    uint256 public constant REWARD_RATE = 100;

    uint256 private s_totalStaked;

    mapping(address => uint256) private s_balances;
    mapping(address => uint256) private s_rewards;

    /**
     * Events
     */
    event Staked(address indexed user, uint256 indexed amount);
    event StakeWithdrawn(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    constructor(address initialOwner, address stakingToken) Ownable(initialOwner) {
        // We assume this contract generates rewards in the same token as the one that is staked.
        // This implies that the amout of stakingToken owned by the contract should always be greater than the reward owed to stakers.
        s_stakingToken = IERC20(stakingToken);
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
}
