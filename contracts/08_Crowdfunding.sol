// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Crowdfunding
 * @dev Goal-and-deadline campaign supporting owner payout on success or one-shot contributor refunds on failure.
 */
contract Crowdfunding {
    struct Contribution {
        address contributor;
        uint256 amount;
    }

    address payable public owner;
    uint256 public goal;
    uint256 public deadline;
    uint256 public raised;
    bool public claimed;

    mapping(address => uint256) public contributions;
    Contribution[] public contributionHistory;

    event Contributed(address indexed contributor, uint256 amount);
    event FundsClaimed(address indexed owner, uint256 amount);
    event Refunded(address indexed contributor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /**
     * @dev Initializes campaign target in wei and active duration in seconds.
     * @param _goal Funding target in wei.
     * @param _durationSeconds Campaign duration from deployment timestamp.
     */
    constructor(uint256 _goal, uint256 _durationSeconds) {
        require(_goal > 0, "Goal must be greater than zero");
        require(_durationSeconds > 0, "Duration must be greater than zero");
        owner = payable(msg.sender);
        goal = _goal;
        deadline = block.timestamp + _durationSeconds;
    }

    /**
     * @dev Accepts ETH contributions before the campaign deadline.
     */
    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign deadline has passed");
        require(msg.value > 0, "Contribution must be greater than zero");

        raised += msg.value;
        contributions[msg.sender] += msg.value;
        contributionHistory.push(Contribution({
            contributor: msg.sender,
            amount: msg.value
        }));

        emit Contributed(msg.sender, msg.value);
    }

    /**
     * @dev Returns seconds left until deadline, or 0 if already expired.
     */
    function getRemainingTime() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    /**
     * @dev Allows owner to claim total raised funds once deadline passes and goal is met.
     */
    function claimFunds() external onlyOwner {
        require(block.timestamp >= deadline, "Campaign is still active");
        require(raised >= goal, "Funding goal not reached");
        require(!claimed, "Funds already claimed");

        claimed = true;
        uint256 amount = address(this).balance;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit FundsClaimed(owner, amount);
    }

    /**
     * @dev Allows contributors to withdraw their contribution once deadline passes and goal failed.
     *      Zeroes caller balance before transfer to make refunds one-shot safe.
     */
    function refund() external {
        require(block.timestamp >= deadline, "Campaign is still active");
        require(raised < goal, "Goal was reached, refunds disabled");

        uint256 contributed = contributions[msg.sender];
        require(contributed > 0, "No contribution to refund");

        // Zero mapping prior to external call (CEI pattern)
        contributions[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: contributed}("");
        require(success, "Refund transfer failed");

        emit Refunded(msg.sender, contributed);
    }
}
