// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MultisigWallet
 * @dev M-of-N multi-signature ETH wallet with owner validation, duplicate-confirmation protection, and auto-execution.
 */
contract MultisigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;
    mapping(uint256 => uint256) public confirmationCount;

    event Submission(uint256 indexed txId);
    event Confirmation(address indexed owner, uint256 indexed txId);
    event Execution(uint256 indexed txId);
    event Deposit(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    /**
     * @dev Registers unique non-zero owners and sets required confirmation threshold.
     */
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners required");
        require(_required > 0 && _required <= _owners.length, "Invalid required confirmations");

        for (uint256 i = 0; i < _owners.length; i++) {
            address ownerAddr = _owners[i];
            require(ownerAddr != address(0), "Invalid zero-address owner");
            require(!isOwner[ownerAddr], "Duplicate owner address");

            isOwner[ownerAddr] = true;
            owners.push(ownerAddr);
        }

        required = _required;
    }

    /**
     * @dev Accepts incoming ETH transfers into the multisig treasury.
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Submits a new ETH transfer proposal and records the proposer's confirmation.
     */
    function submitTransaction(address to, uint256 value) external onlyOwner {
        require(to != address(0), "Invalid recipient address");

        uint256 txId = transactions.length;
        transactions.push(Transaction({
            to: to,
            value: value,
            executed: false
        }));
        emit Submission(txId);

        confirmed[txId][msg.sender] = true;
        confirmationCount[txId] = 1;
        emit Confirmation(msg.sender, txId);

        if (confirmationCount[txId] >= required) {
            _executeTransaction(txId);
        }
    }

    /**
     * @dev Adds an owner's confirmation to txId; auto-executes once required count is met.
     */
    function confirmTransaction(uint256 txId) external onlyOwner {
        require(txId < transactions.length, "Transaction does not exist");
        require(!transactions[txId].executed, "Transaction already executed");
        require(!confirmed[txId][msg.sender], "Transaction already confirmed by owner");

        confirmed[txId][msg.sender] = true;
        confirmationCount[txId] += 1;
        emit Confirmation(msg.sender, txId);

        if (confirmationCount[txId] >= required) {
            _executeTransaction(txId);
        }
    }

    /**
     * @dev Manually triggers execution of a transaction that has reached required confirmations.
     */
    function executeTransaction(uint256 txId) external onlyOwner {
        _executeTransaction(txId);
    }

    /**
     * @dev Internal CEI execution guard ensuring single-execution invariant.
     */
    function _executeTransaction(uint256 txId) internal {
        require(txId < transactions.length, "Transaction does not exist");
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Transaction already executed");
        require(confirmationCount[txId] >= required, "Not enough confirmations");
        require(address(this).balance >= txn.value, "Insufficient wallet balance");

        txn.executed = true;

        (bool success, ) = payable(txn.to).call{value: txn.value}("");
        require(success, "Transaction execution failed");

        emit Execution(txId);
    }

    /**
     * @dev Returns total number of owner confirmations for txId.
     */
    function getConfirmations(uint256 txId) external view returns (uint256) {
        require(txId < transactions.length, "Transaction does not exist");
        return confirmationCount[txId];
    }
}
