// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev Reusable ownership base contract with transfer and access control modifier.
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
     * @dev Transfers ownership to a non-zero address.
     * @param newOwner Address of the next owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}

/**
 * @title ProtectedVault
 * @dev Inherits Ownable to guard ETH withdrawals while allowing public deposits.
 */
contract ProtectedVault is Ownable {
    uint256 private treasure;

    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    /**
     * @dev Accepts ETH deposits from any account.
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        treasure += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraws ETH to a target address. Only callable by the current owner.
     * @param to Recipient address.
     * @param amt Amount in wei to withdraw.
     */
    function withdraw(address to, uint256 amt) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(amt > 0, "Amount must be greater than zero");
        require(amt <= address(this).balance && amt <= treasure, "Insufficient vault balance");

        // Update state before external interaction
        treasure -= amt;

        (bool success, ) = payable(to).call{value: amt}("");
        require(success, "ETH transfer failed");

        emit Withdrawn(to, amt);
    }

    /**
     * @dev Returns current ETH balance held by the vault contract.
     */
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
