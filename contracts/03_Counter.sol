// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Counter
 * @dev Bounded counter within [0, MAX] with event emission on every state mutation.
 */
contract Counter {
    uint256 public count;
    uint256 public constant MAX = 100;

    event Incremented(address indexed caller, uint256 newCount);
    event Decremented(address indexed caller, uint256 newCount);
    event Reset(address indexed caller);

    /**
     * @dev Increments count by 1; reverts if count has reached MAX.
     */
    function increment() public {
        require(count < MAX, "Max limit reached");
        count += 1;
        emit Incremented(msg.sender, count);
    }

    /**
     * @dev Decrements count by 1; reverts if count is already 0.
     */
    function decrement() public {
        require(count > 0, "Count is zero");
        count -= 1;
        emit Decremented(msg.sender, count);
    }

    /**
     * @dev Explicitly resets count back to 0.
     */
    function reset() public {
        count = 0;
        emit Reset(msg.sender);
    }
}
