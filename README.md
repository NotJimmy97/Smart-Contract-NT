# Solidity Smart Contract Assignment
**Name:** Nguyễn Nhật Tú
**Roll No:** 29211438698
**Email:** nguyennhattu3@dtu.edu.vn (`nhattunguyen97@gmail.com`)
**GitHub:** [NotJimmy97](https://github.com/NotJimmy97)

| # | Contract | Level | Tested on Ganache | Screenshots |
|---|---|---|---|---|
| 01 | [Storage](contracts/01_Storage.sol) | Basic | YES | [01_compile.png](screenshots/01_compile.png), [01_test1.png](screenshots/01_test1.png), [01_test2.png](screenshots/01_test2.png) |
| 02 | [Greeting](contracts/02_Greeting.sol) | Basic | YES | [02_compile.png](screenshots/02_compile.png), [02_test1.png](screenshots/02_test1.png), [02_test2.png](screenshots/02_test2.png) |
| 03 | [Counter](contracts/03_Counter.sol) | Basic | YES | [03_compile.png](screenshots/03_compile.png), [03_test1.png](screenshots/03_test1.png), [03_test2.png](screenshots/03_test2.png) |
| 04 | [Ownable & ProtectedVault](contracts/04_Ownable.sol) | Medium | YES | [04_compile.png](screenshots/04_compile.png), [04_test1.png](screenshots/04_test1.png), [04_test2.png](screenshots/04_test2.png) |
| 05 | [SimpleBank](contracts/05_SimpleBank.sol) | Medium | YES | [05_compile.png](screenshots/05_compile.png), [05_test1.png](screenshots/05_test1.png), [05_test2.png](screenshots/05_test2.png) |
| 06 | [Voting](contracts/06_Voting.sol) | Medium | YES | [06_compile.png](screenshots/06_compile.png), [06_test1.png](screenshots/06_test1.png), [06_test2.png](screenshots/06_test2.png) |
| 07 | [MyToken](contracts/07_MyToken.sol) | Medium | YES | [07_compile.png](screenshots/07_compile.png), [07_test1.png](screenshots/07_test1.png), [07_test2.png](screenshots/07_test2.png) |
| 08 | [Crowdfunding](contracts/08_Crowdfunding.sol) | Advanced | YES | [08_compile.png](screenshots/08_compile.png), [08_test1.png](screenshots/08_test1.png), [08_test2.png](screenshots/08_test2.png) |
| 09 | [Lottery](contracts/09_Lottery.sol) | Advanced | YES | [09_compile.png](screenshots/09_compile.png), [09_test1.png](screenshots/09_test1.png), [09_test2.png](screenshots/09_test2.png) |
| 10 | [TimeLockVault](contracts/10_TimeLockVault.sol) | Advanced | YES | [10_compile.png](screenshots/10_compile.png), [10_test1.png](screenshots/10_test1.png), [10_test2.png](screenshots/10_test2.png) |
| 11 | [Escrow](contracts/11_Escrow.sol) | Advanced | YES | [11_compile.png](screenshots/11_compile.png), [11_test1.png](screenshots/11_test1.png), [11_test2.png](screenshots/11_test2.png) |
| 12 | [SimpleNFT](contracts/12_SimpleNFT.sol) | Advanced | YES | [12_compile.png](screenshots/12_compile.png), [12_test1.png](screenshots/12_test1.png), [12_test2.png](screenshots/12_test2.png) |
| 13 | [EnglishAuction](contracts/13_EnglishAuction.sol) | Expert | YES | [13_compile.png](screenshots/13_compile.png), [13_test1.png](screenshots/13_test1.png), [13_test2.png](screenshots/13_test2.png) |
| 14 | [MultisigWallet](contracts/14_MultisigWallet.sol) | Expert | YES | [14_compile.png](screenshots/14_compile.png), [14_test1.png](screenshots/14_test1.png), [14_test2.png](screenshots/14_test2.png) |
| 15 | [StakingRewards](contracts/15_StakingRewards.sol) | Expert | YES | [15_compile.png](screenshots/15_compile.png), [15_test1.png](screenshots/15_test1.png), [15_test2.png](screenshots/15_test2.png) |

## How to run
1. Open [Remix IDE](https://remix.ethereum.org) -> paste/open contract from `contracts/` -> compile with Solidity `0.8.x` (set **Advanced Configurations -> EVM Version: `shanghai`** when using Solidity `>= 0.8.25` with Ganache so `MCOPY` opcodes are avoided).
2. Start Ganache QUICKSTART on `http://127.0.0.1:7545` (Chain ID `1337`).
3. In Remix Deploy & Run: set **Environment -> Custom - External Http Provider** (`http://127.0.0.1:7545`).
4. Deploy and test every happy path, edge case, and revert condition per [report/REPORT.md](report/REPORT.md).

## Documentation
- Detailed per-contract test proofs and security design analysis: [report/REPORT.md](report/REPORT.md)
- Verified screenshots: `45` PNG captures in `screenshots/` (`compile`, happy path `test1`, revert/edge `test2` for all 15 contracts).
