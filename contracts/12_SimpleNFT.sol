// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleNFT
 * @dev Minimal ERC-721 style NFT collection built from scratch without external imports.
 */
contract SimpleNFT {
    string public name;
    string public symbol;
    address public owner;
    uint256 public nextTokenId;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public mintPrice = 0.01 ether;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approvals;

    event Minted(address indexed to, uint256 indexed tokenId);
    event TransferNFT(address indexed from, address indexed to, uint256 indexed tokenId);
    event ApprovalNFT(address indexed owner, address indexed spender, uint256 indexed tokenId);
    event PaymentsWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner allowed");
        _;
    }

    /**
     * @dev Initializes NFT collection metadata and contract owner.
     */
    constructor() {
        name = "SimpleNFT";
        symbol = "SNFT";
        owner = msg.sender;
    }

    /**
     * @dev Mints the next sequential tokenId upon exact payment of mintPrice.
     */
    function mint() external payable returns (uint256) {
        require(nextTokenId < MAX_SUPPLY, "Max supply reached");
        require(msg.value == mintPrice, "Must send exact mint price");

        uint256 tokenId = nextTokenId;
        nextTokenId += 1;
        ownerOf[tokenId] = msg.sender;
        balances[msg.sender] += 1;

        emit Minted(msg.sender, tokenId);
        emit TransferNFT(address(0), msg.sender, tokenId);
        return tokenId;
    }

    /**
     * @dev Transfers an owned NFT directly to another non-zero address.
     */
    function transferNFT(address to, uint256 tokenId) external {
        require(to != address(0), "Transfer to zero address");
        require(ownerOf[tokenId] == msg.sender, "Not the token owner");

        delete approvals[tokenId];
        balances[msg.sender] -= 1;
        balances[to] += 1;
        ownerOf[tokenId] = to;

        emit TransferNFT(msg.sender, to, tokenId);
    }

    /**
     * @dev Approves a spender address to transfer a specific tokenId.
     */
    function approve(address spender, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not the token owner");
        require(spender != address(0), "Approve to zero address");
        require(spender != msg.sender, "Cannot approve current owner");

        approvals[tokenId] = spender;
        emit ApprovalNFT(msg.sender, spender, tokenId);
    }

    /**
     * @dev Executes an approved third-party NFT transfer (ERC-721 style).
     */
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(to != address(0), "Transfer to zero address");
        require(ownerOf[tokenId] == from, "From address is not owner");
        require(
            msg.sender == approvals[tokenId] || msg.sender == from,
            "Caller is not approved or owner"
        );

        delete approvals[tokenId];
        balances[from] -= 1;
        balances[to] += 1;
        ownerOf[tokenId] = to;

        emit TransferNFT(from, to, tokenId);
    }

    /**
     * @dev Allows contract owner to withdraw accumulated mint revenue.
     */
    function withdrawPayments() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No mint revenue to withdraw");

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Withdrawal transfer failed");

        emit PaymentsWithdrawn(owner, amount);
    }
}
