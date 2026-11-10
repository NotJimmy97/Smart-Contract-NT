// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Voting
 * @dev Chairperson-managed election where authorized voters cast a single vote.
 */
contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint256 voteIndex;
    }

    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    address public chairperson;

    event VoterAuthorized(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateIndex);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this");
        _;
    }

    /**
     * @dev Sets deployer as chairperson and registers candidate names.
     * @param candidateNames List of candidate names.
     */
    constructor(string[] memory candidateNames) {
        require(candidateNames.length > 0, "At least one candidate required");
        chairperson = msg.sender;

        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    /**
     * @dev Authorizes an address to vote once. Restricted to chairperson.
     * @param voter Address to authorize.
     */
    function authorize(address voter) external onlyChairperson {
        require(voter != address(0), "Invalid voter address");
        require(!voters[voter].authorized, "Voter is already authorized");
        voters[voter].authorized = true;
        emit VoterAuthorized(voter);
    }

    /**
     * @dev Casts a single vote for candidate at candidateIndex.
     * @param candidateIndex Zero-based index into candidates array.
     */
    function vote(uint256 candidateIndex) external {
        Voter storage sender = voters[msg.sender];
        require(sender.authorized, "Not authorized to vote");
        require(!sender.voted, "Already voted");
        require(candidateIndex < candidates.length, "Invalid candidate index");

        sender.voted = true;
        sender.voteIndex = candidateIndex;
        candidates[candidateIndex].voteCount += 1;

        emit VoteCast(msg.sender, candidateIndex);
    }

    /**
     * @dev Returns vote count for a specific candidate index.
     */
    function totalVotes(uint256 candidateIndex) external view returns (uint256) {
        require(candidateIndex < candidates.length, "Invalid candidate index");
        return candidates[candidateIndex].voteCount;
    }

    /**
     * @dev Scans all candidates and returns the leading candidate's name.
     */
    function winnerName() external view returns (string memory) {
        uint256 winningVoteCount = 0;
        uint256 winningIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningIndex = i;
            }
        }

        return candidates[winningIndex].name;
    }
}
