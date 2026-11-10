// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EnglishAuction
 * @dev Timed English auction using the Pull-Payment (withdrawal) pattern for outbid refunds.
 */
contract EnglishAuction {
    address payable public seller;
    uint256 public auctionEnd;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public constant MIN_INCREMENT = 5; // 5% minimum raise
    mapping(address => uint256) public pendingReturns;
    bool public ended;

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event PendingWithdrawn(address indexed bidder, uint256 amount);

    /**
     * @dev Initializes seller, bidding deadline, and reserve start price.
     * @param _biddingSeconds Auction duration in seconds.
     * @param _startPrice Minimum opening bid in wei.
     */
    constructor(uint256 _biddingSeconds, uint256 _startPrice) {
        require(_biddingSeconds > 0, "Bidding duration must be positive");
        require(_startPrice > 0, "Start price must be positive");
        seller = payable(msg.sender);
        auctionEnd = block.timestamp + _biddingSeconds;
        highestBid = _startPrice;
    }

    /**
     * @dev Places a higher bid. Credits the outbid leader into pendingReturns instead of pushing ETH.
     */
    function bid() external payable {
        require(!ended && block.timestamp < auctionEnd, "Auction already ended");
        require(msg.sender != seller, "Seller cannot bid");

        if (highestBidder == address(0)) {
            require(msg.value >= highestBid, "Bid must be at least start price");
        } else {
            uint256 minRequired = (highestBid * (100 + MIN_INCREMENT)) / 100;
            require(msg.value >= minRequired, "Bid must exceed highest bid by at least 5%");
            // Pull-payment pattern: never push ETH inside bid()
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewBid(msg.sender, msg.value);
    }

    /**
     * @dev Allows outbid participants to safely pull their own refundable ETH.
     */
    function withdrawPending() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No pending returns to withdraw");

        // Zero balance before external call (CEI pattern)
        pendingReturns[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            pendingReturns[msg.sender] = amount;
            return false;
        }

        emit PendingWithdrawn(msg.sender, amount);
        return true;
    }

    /**
     * @dev Finalizes the auction after auctionEnd and pays the seller if a bid was placed.
     */
    function endAuction() external {
        require(block.timestamp >= auctionEnd, "Auction has not ended yet");
        require(!ended, "Auction already ended");

        ended = true;

        if (highestBidder != address(0)) {
            (bool success, ) = seller.call{value: highestBid}("");
            require(success, "Seller payout failed");
            emit AuctionEnded(highestBidder, highestBid);
        } else {
            emit AuctionEnded(address(0), 0);
        }
    }
}
