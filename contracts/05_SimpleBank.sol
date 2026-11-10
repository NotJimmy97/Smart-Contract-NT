// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleBank
 * @dev Per-user ETH vault enforcing the Checks-Effects-Interactions pattern.
 */
contract SimpleBank {
    mapping(address => uint256) private balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Deposits sent ETH into the caller's on-chain ledger balance.
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraws caller's ETH following Checks-Effects-Interactions to block re-entrancy.
     * @param amount Amount in wei to withdraw.
     */
    function withdraw(uint256 amount) public {
        // 1. Checks
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 2. Effects (mutate state BEFORE external call)
        balances[msg.sender] -= amount;

        // 3. Interactions
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Returns caller's current deposited balance in wei.
     */
    function myBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @dev Returns total ETH currently locked inside the bank contract.
     */
    function bankTotal() public view returns (uint256) {
        return address(this).balance;
    }
}
