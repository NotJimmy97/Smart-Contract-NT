# Smart-Contract-NT

Collection of 15 standalone Solidity smart contracts (`pragma solidity ^0.8.0`, MIT License) progressive from basic state storage to advanced DeFi/governance patterns, compiled and verified on Remix IDE.

## Repository Structure

```text
.
├── contracts/       # 15 standalone Solidity contracts (01 -> 15)
├── screenshots/     # Remix IDE compilation & transaction verification captures
└── README.md
```

## Smart Contracts

| # | File | Contract(s) | Level | Description |
| :-: | :--- | :--- | :--- | :--- |
| 01 | `contracts/01_Storage.sol` | `Storage` | Basic | On-chain `uint256` storage with constructor initialization and `ValueSet` event |
| 02 | `contracts/02_Greeting.sol` | `Greeting` | Basic | Owner-restricted greeting message with `GreetingChanged` event |
| 03 | `contracts/03_Counter.sol` | `Counter` | Basic | Bounded counter within `[0, 100]` (`increment`, `decrement`, `reset`) |
| 04 | `contracts/04_Ownable.sol` | `Ownable`, `ProtectedVault` | Medium | Reusable ownership access control with ETH vault enforcing CEI |
| 05 | `contracts/05_SimpleBank.sol` | `SimpleBank` | Medium | Per-user ETH deposit/withdrawal vault using Checks-Effects-Interactions |
| 06 | `contracts/06_Voting.sol` | `Voting` | Medium | Chairperson-managed election with voter authorization and one-vote enforcement |
| 07 | `contracts/07_MyToken.sol` | `MyToken` | Medium | Minimal ERC-20 style fungible token built from scratch (`transfer`, `approve`, `transferFrom`) |
| 08 | `contracts/08_Crowdfunding.sol` | `Crowdfunding` | Advanced | Goal-and-deadline campaign with owner payout or contributor refunds |
| 09 | `contracts/09_Lottery.sol` | `Lottery` | Advanced | Fixed-fee multi-player lottery with manager-triggered winner selection |
| 10 | `contracts/10_TimeLockVault.sol` | `TimeLockVault` | Advanced | ETH vault locked until a future `block.timestamp` for a beneficiary |
| 11 | `contracts/11_Escrow.sol` | `Escrow` | Advanced | Three-party state-machine escrow (`buyer`, `seller`, `arbiter`) with dispute resolution |
| 12 | `contracts/12_SimpleNFT.sol` | `SimpleNFT` | Advanced | Minimal ERC-721 style NFT collection built from scratch (`MAX_SUPPLY = 100`) |
| 13 | `contracts/13_EnglishAuction.sol` | `EnglishAuction` | Expert | Timed English auction using Pull-Payment (`pendingReturns`) for outbid refunds |
| 14 | `contracts/14_MultisigWallet.sol` | `MultisigWallet` | Expert | M-of-N multi-signature ETH wallet with duplicate-confirmation guard & auto-execution |
| 15 | `contracts/15_StakingRewards.sol` | `StakingRewards` | Expert | Continuous per-second ETH staking rewards funded from `rewardPool` |

## Compile & Test

All contracts use `pragma solidity ^0.8.0` with zero external library imports and can be compiled and deployed directly in [Remix IDE](https://remix.ethereum.org/) or locally with `solc`:

```bash
solc --optimize --bin contracts/01_Storage.sol
```
