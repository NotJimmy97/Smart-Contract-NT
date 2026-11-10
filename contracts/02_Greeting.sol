// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Greeting
 * @dev Stores a greeting message modifiable only by the deployer/owner.
 */
contract Greeting {
    string private greeting;
    address public owner;

    event GreetingChanged(address changer, string newGreeting);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    /**
     * @dev Sets deployer as owner and initializes the greeting message.
     * @param _g Initial greeting text.
     */
    constructor(string memory _g) {
        owner = msg.sender;
        greeting = _g;
        emit GreetingChanged(msg.sender, _g);
    }

    /**
     * @dev Updates the greeting message. Restricted to owner.
     * @param _g New greeting text.
     */
    function setGreeting(string memory _g) public onlyOwner {
        greeting = _g;
        emit GreetingChanged(msg.sender, _g);
    }

    /**
     * @dev Returns the current greeting message.
     */
    function greet() public view returns (string memory) {
        return greeting;
    }

    /**
     * @dev Resets the greeting back to "Hello, World!". Restricted to owner.
     */
    function resetGreeting() public onlyOwner {
        greeting = "Hello, World!";
        emit GreetingChanged(msg.sender, "Hello, World!");
    }
}
