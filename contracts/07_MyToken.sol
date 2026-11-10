// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MyToken
 * @dev Minimal ERC-20 style fungible token built from scratch without external imports.
 */
contract MyToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Mints the entire initial supply to the deployer account.
     * @param _n Token name.
     * @param _s Token symbol.
     * @param _supply Initial total supply.
     */
    constructor(string memory _n, string memory _s, uint256 _supply) {
        name = _n;
        symbol = _s;
        totalSupply = _supply;
        balanceOf[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, _supply);
    }

    /**
     * @dev Transfers tokens from caller to recipient.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Sets spending allowance for a spender on caller's tokens.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Approve to zero address");
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfers tokens from `from` to `to` using the caller's approved allowance.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");

        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
        return true;
    }
}
