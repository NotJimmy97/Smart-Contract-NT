// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Storage
 * @dev Simple on-chain unsigned integer storage with event logging.
 */
contract Storage {
    uint256 private storedData;

    event ValueSet(address indexed who, uint256 newValue);

    /**
     * @dev Initializes storedData at deployment.
     * @param _init Initial unsigned integer value.
     */
    constructor(uint256 _init) {
        storedData = _init;
    }

    /**
     * @dev Updates storedData and emits ValueSet event.
     * @param _value New unsigned integer value to store.
     */
    function set(uint256 _value) public {
        storedData = _value;
        emit ValueSet(msg.sender, _value);
    }

    /**
     * @dev Reads storedData without consuming gas when called externally.
     */
    function get() public view returns (uint256) {
        return storedData;
    }
}
