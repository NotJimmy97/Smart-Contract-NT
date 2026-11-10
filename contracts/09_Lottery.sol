// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lottery
 * @dev Fixed-fee multi-player lottery where the manager triggers winner selection and pot payout.
 */
contract Lottery {
    address payable[] private players;
    address public manager;
    uint256 public entryFee;
    uint256 public minPlayers;

    event PlayerEntered(address indexed player, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 amount);

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    /**
     * @dev Sets deployer as manager with default 0.01 ETH entry fee and > 3 players requirement.
     */
    constructor() {
        manager = msg.sender;
        entryFee = 0.01 ether;
        minPlayers = 3;
    }

    /**
     * @dev Enters caller into current lottery round for exact entryFee. Manager is excluded.
     */
    function enter() public payable {
        require(msg.sender != manager, "Manager cannot enter the lottery");
        require(msg.value == entryFee, "Must pay exact entry fee");

        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, msg.value);
    }

    /**
     * @dev Returns number of players in the current round.
     */
    function playersCount() public view returns (uint256) {
        return players.length;
    }

    /**
     * @dev Returns all player addresses currently in the round.
     */
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    /**
     * @dev Selects a pseudo-random winner using blockhash, resets round state, and pays full pot.
     *      Note: blockhash is used for educational demo only; production requires Chainlink VRF.
     */
    function pickWinner() public onlyManager {
        require(players.length > minPlayers, "Not enough players");

        uint256 randomIndex = uint256(blockhash(block.number - 1)) % players.length;
        address payable winner = players[randomIndex];
        uint256 prize = address(this).balance;

        // Reset round before external payout (CEI pattern)
        delete players;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Winner payout failed");

        emit WinnerSelected(winner, prize);
    }
}
