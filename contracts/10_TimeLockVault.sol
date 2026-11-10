// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TimeLockVault
 * @dev ETH vault locked until a future block timestamp, withdrawable only by beneficiary.
 */
contract TimeLockVault {
    address payable public beneficiary;
    uint256 public unlockTime;

    event Deposited(address indexed from, uint256 amount, uint256 newUnlockTime);
    event Withdrawn(address indexed to, uint256 amount);
    event LockExtended(uint256 newUnlockTime);

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Only beneficiary can call this");
        _;
    }

    /**
     * @dev Sets beneficiary address and initial unlock timestamp.
     * @param _beneficiary Address authorized to withdraw after unlockTime.
     * @param _lockSeconds Initial lock duration in seconds.
     */
    constructor(address payable _beneficiary, uint256 _lockSeconds) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_lockSeconds > 0, "Lock duration must be positive");
        beneficiary = _beneficiary;
        unlockTime = block.timestamp + _lockSeconds;
    }

    /**
     * @dev Accepts ETH deposits from any address without altering unlockTime.
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    /**
     * @dev Extends lock duration by extra seconds. Restricted to beneficiary.
     */
    function extendLock(uint256 _extraSeconds) external onlyBeneficiary {
        require(_extraSeconds > 0, "Extra seconds must be positive");
        unlockTime += _extraSeconds;
        emit LockExtended(unlockTime);
    }

    /**
     * @dev Withdraws entire contract balance after block.timestamp passes unlockTime.
     */
    function withdraw() external onlyBeneficiary {
        require(block.timestamp > unlockTime, "Vault is still locked");
        uint256 amount = address(this).balance;
        require(amount > 0, "Vault balance is empty");

        (bool success, ) = beneficiary.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawn(beneficiary, amount);
    }

    /**
     * @dev Returns remaining lock seconds, or 0 once unlocked.
     */
    function timeRemaining() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
}
