// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title StakingRewards
 * @dev Continuous per-second ETH staking rewards funded from an owner-managed rewardPool.
 */
contract StakingRewards {
    address payable public owner;
    uint256 public rewardRatePerSecond; // wei of reward per 1 ETH staked per second
    uint256 public totalStaked;
    uint256 public rewardPool;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 rewardDebt;
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 principal, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardPoolFunded(address indexed sender, uint256 amount);
    event RewardRateUpdated(uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /**
     * @dev Sets initial reward rate and seeds rewardPool with attached msg.value.
     * @param _rate Reward in wei per 1 ETH staked per second.
     */
    constructor(uint256 _rate) payable {
        owner = payable(msg.sender);
        rewardRatePerSecond = _rate;
        rewardPool = msg.value;
        if (msg.value > 0) {
            emit RewardPoolFunded(msg.sender, msg.value);
        }
    }

    /**
     * @dev Stakes ETH and snapshots previously accrued rewards into rewardDebt before updating principal.
     */
    function stake() external payable {
        require(msg.value > 0, "Stake amount must be greater than zero");

        Stake storage userStake = stakes[msg.sender];
        if (userStake.amount > 0) {
            userStake.rewardDebt = pendingReward(msg.sender);
        }

        userStake.amount += msg.value;
        userStake.startTime = block.timestamp;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    /**
     * @dev Computes accrued reward as rewardDebt + (amount * rate * elapsed) / 1 ether.
     */
    function pendingReward(address user) public view returns (uint256) {
        Stake memory userStake = stakes[user];
        if (userStake.amount == 0) {
            return userStake.rewardDebt;
        }
        uint256 elapsed = block.timestamp - userStake.startTime;
        uint256 accrued = (userStake.amount * rewardRatePerSecond * elapsed) / 1 ether;
        return userStake.rewardDebt + accrued;
    }

    /**
     * @dev Withdraws principal plus accrued reward; resets stake state atomically (CEI).
     */
    function unstake() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No active stake to unstake");

        uint256 principal = userStake.amount;
        uint256 reward = pendingReward(msg.sender);
        require(reward <= rewardPool, "Insufficient reward pool");

        // Effects before Interactions (one-shot safe)
        totalStaked -= principal;
        rewardPool -= reward;
        delete stakes[msg.sender];

        uint256 payout = principal + reward;
        (bool success, ) = payable(msg.sender).call{value: payout}("");
        require(success, "Unstake transfer failed");

        emit Unstaked(msg.sender, principal, reward);
    }

    /**
     * @dev Claims accumulated reward only while keeping principal staked and earning.
     */
    function claimReward() external {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0 || userStake.rewardDebt > 0, "No active stake");

        uint256 reward = pendingReward(msg.sender);
        require(reward > 0, "No reward available");
        require(reward <= rewardPool, "Insufficient reward pool");

        // Effects before Interactions
        userStake.rewardDebt = 0;
        userStake.startTime = block.timestamp;
        rewardPool -= reward;

        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "Reward transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Allows owner to top up the reward pool.
     */
    function fundRewards() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH to fund rewards");
        rewardPool += msg.value;
        emit RewardPoolFunded(msg.sender, msg.value);
    }

    /**
     * @dev Updates reward rate per second. Restricted to owner.
     */
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRatePerSecond = _newRate;
        emit RewardRateUpdated(_newRate);
    }
}
