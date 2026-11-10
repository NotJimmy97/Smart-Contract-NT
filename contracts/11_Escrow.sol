// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Escrow
 * @dev Three-party state-machine escrow (buyer, seller, arbiter) with dispute resolution.
 */
contract Escrow {
    enum State {
        AwaitingPayment,
        AwaitingDelivery,
        Complete,
        Refunded,
        Disputed
    }

    address payable public buyer;
    address payable public seller;
    address payable public arbiter;
    State public state;

    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event BuyerRefunded(address indexed actor, address indexed buyer, uint256 amount);
    event DisputeRaised(address indexed raisedBy);
    event DisputeResolved(address indexed arbiter, address indexed recipient, uint256 amount);

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer allowed");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter allowed");
        _;
    }

    modifier onlyBuyerOrSeller() {
        require(msg.sender == buyer || msg.sender == seller, "Only buyer or seller allowed");
        _;
    }

    modifier onlyArbiterOrSeller() {
        require(msg.sender == arbiter || msg.sender == seller, "Only arbiter or seller allowed");
        _;
    }

    modifier stateCheck(State expected) {
        require(state == expected, "Invalid escrow state");
        _;
    }

    /**
     * @dev Sets deployer as buyer; moves immediately to AwaitingDelivery if ETH is attached.
     */
    constructor(address payable _seller, address payable _arbiter) payable {
        require(_seller != address(0) && _arbiter != address(0), "Invalid party address");
        require(
            _seller != msg.sender && _arbiter != msg.sender && _seller != _arbiter,
            "Buyer, seller, and arbiter must be distinct"
        );

        buyer = payable(msg.sender);
        seller = _seller;
        arbiter = _arbiter;

        if (msg.value > 0) {
            state = State.AwaitingDelivery;
            emit PaymentDeposited(msg.sender, msg.value);
        } else {
            state = State.AwaitingPayment;
        }
    }

    /**
     * @dev Allows buyer to fund escrow if deployed without initial ETH.
     */
    function depositPayment() external payable onlyBuyer stateCheck(State.AwaitingPayment) {
        require(msg.value > 0, "Payment must be greater than zero");
        state = State.AwaitingDelivery;
        emit PaymentDeposited(msg.sender, msg.value);
    }

    /**
     * @dev Buyer confirms delivery, transitioning to Complete and paying the seller.
     */
    function confirmDelivery() external onlyBuyer stateCheck(State.AwaitingDelivery) {
        state = State.Complete;
        uint256 amount = address(this).balance;

        (bool success, ) = seller.call{value: amount}("");
        require(success, "Payment to seller failed");

        emit DeliveryConfirmed(buyer, seller, amount);
    }

    /**
     * @dev Seller or arbiter voluntarily refunds the buyer before completion.
     */
    function refundBuyer() external onlyArbiterOrSeller stateCheck(State.AwaitingDelivery) {
        state = State.Refunded;
        uint256 amount = address(this).balance;

        (bool success, ) = buyer.call{value: amount}("");
        require(success, "Refund to buyer failed");

        emit BuyerRefunded(msg.sender, buyer, amount);
    }

    /**
     * @dev Either buyer or seller freezes funds into Disputed state for arbitration.
     */
    function raiseDispute() external onlyBuyerOrSeller stateCheck(State.AwaitingDelivery) {
        state = State.Disputed;
        emit DisputeRaised(msg.sender);
    }

    /**
     * @dev Arbiter resolves dispute in favor of seller.
     */
    function resolveToSeller() external onlyArbiter stateCheck(State.Disputed) {
        state = State.Complete;
        uint256 amount = address(this).balance;

        (bool success, ) = seller.call{value: amount}("");
        require(success, "Resolution transfer failed");

        emit DisputeResolved(arbiter, seller, amount);
    }

    /**
     * @dev Arbiter resolves dispute in favor of buyer.
     */
    function resolveToBuyer() external onlyArbiter stateCheck(State.Disputed) {
        state = State.Refunded;
        uint256 amount = address(this).balance;

        (bool success, ) = buyer.call{value: amount}("");
        require(success, "Resolution transfer failed");

        emit DisputeResolved(arbiter, buyer, amount);
    }
}
