# Smart Contract Development Assignment — Verification Report

- **Student:** Nguyễn Nhật Tú
- **Roll No (Student ID):** `29211438698`
- **Email:** `nguyennhattu3@dtu.edu.vn` / `nhattunguyen97@gmail.com`
- **Toolchain:** Solidity `^0.8.0` (`solc 0.8.34` in Remix IDE `2.6.13` + `solc 0.8.38`, `evmVersion: shanghai`), Ganache (`HTTP://127.0.0.1:7545`, Chain ID `1337`), Web3 Custom External HTTP Provider.

---

## 01 Storage
- What it does : stores and updates a single unsigned integer on-chain with `ValueSet` event logging.
- Key concept  : state variables, constructor initialization, gas-free `view` getters, indexed events.
- Tested       : deployed with `42`, `get()` -> `42`, `set(100)` from Account 1, `set(2026)` from Account 2, verified `ValueSet` log in Ganache.
- Ganache proof: `screenshots/01_compile.png`, `screenshots/01_test1.png`, `screenshots/01_test2.png`

## 02 Greeting
- What it does : stores a configurable greeting string readable by anyone and updatable/resettable only by the owner.
- Key concept  : `onlyOwner` access control with `require()` revert strings and `GreetingChanged` event.
- Tested       : `greet()` -> `"Hello, World!"`, owner `setGreeting("GM Ganache")` & `resetGreeting()`, non-owner `setGreeting("Unauthorized")` -> reverted.
- Ganache proof: `screenshots/02_compile.png`, `screenshots/02_test1.png`, `screenshots/02_test2.png`

## 03 Counter
- What it does : bounded counter enforcing `[0, 100]` (`MAX = 100`) with `increment`, `decrement`, and `reset`.
- Key concept  : boundary invariants via `require()`, Solidity `0.8.x` arithmetic safety, explicit reset with event emission.
- Tested       : `increment()` -> `decrement()` -> `reset()`, underflow `decrement()` at `0` -> reverted, 100 increments (`count() == 100`), 101st `increment()` -> reverted.
- Ganache proof: `screenshots/03_compile.png`, `screenshots/03_test1.png`, `screenshots/03_test2.png`

## 04 Ownable & ProtectedVault
- What it does : reusable `Ownable` base contract inherited by `ProtectedVault` to accept public ETH deposits and restrict withdrawals to the owner.
- Key concept  : contract inheritance (`is Ownable`), `modifier` code reuse, `transferOwnership` non-zero guard, safe `payable` transfers.
- Tested       : `deposit()` `1 ETH`, non-owner `withdraw()` -> reverted, `transferOwnership(Account 1)`, new owner `withdraw(Account 2, 1 ETH)`, former owner `withdraw()` & zero-owner transfer -> reverted.
- Ganache proof: `screenshots/04_compile.png`, `screenshots/04_test1.png`, `screenshots/04_test2.png`

## 05 SimpleBank
- What it does : per-account on-chain ETH ledger supporting arbitrary user deposits and withdrawals.
- Key concept  : Checks-Effects-Interactions (CEI) ordering (`balances[msg.sender] -= amount` before `call{value: amount}("")`) to block re-entrancy.
- Tested       : Account 0 deposits `2 ETH`, Account 1 deposits `3 ETH` (`bankTotal() == 5 ETH`), Account 0 withdraws `1 ETH` (`myBalance() == 1 ETH`), withdraw `10 ETH` & zero-balance withdraw -> reverted.
- Ganache proof: `screenshots/05_compile.png`, `screenshots/05_test1.png`, `screenshots/05_test2.png`

## 06 Voting
- What it does : chairperson registers candidates and authorizes voters; each voter casts a single ballot and `winnerName()` computes the leader.
- Key concept  : `struct` arrays, `mapping(address => Voter)` double-vote prevention, role separation (`onlyChairperson`).
- Tested       : 3 candidates (`Alice`, `Bob`, `Carol`), authorized Accounts 0–2 cast votes (`Bob: 2, Alice: 1`), `winnerName()` -> `"Bob"`, double vote & unauthorized voter -> reverted.
- Ganache proof: `screenshots/06_compile.png`, `screenshots/06_test1.png`, `screenshots/06_test2.png`

## 07 MyToken
- What it does : minimal ERC-20 style fungible token (`TuToken` / `TUT`) implemented from scratch with `transfer`, `approve`, and `transferFrom`.
- Key concept  : nested `allowance[owner][spender]` ledger powering the two-step delegated transfer pattern used by DEXes.
- Tested       : supply `1,000,000`, `transfer(Account 1, 500)`, Account 1 `approve(Account 2, 200)`, Account 2 `transferFrom(Account 1, Account 3, 200)`, second `transferFrom` & insufficient balance `transfer` -> reverted.
- Ganache proof: `screenshots/07_compile.png`, `screenshots/07_test1.png`, `screenshots/07_test2.png`

## 08 Crowdfunding
- What it does : deadline-based fundraising where the owner claims ETH if `raised >= goal`, or contributors reclaim one-shot refunds on failure.
- Key concept  : `block.timestamp` deadline state machine and CEI mapping-zeroing (`contributions[msg.sender] = 0`) for safe refunds.
- Tested       : Campaign A (`goal = 2 ETH`) meets target -> `claimFunds()` empties balance; Campaign B (`goal = 5 ETH`) misses target with `1 ETH` -> `refund()` succeeds, second `refund()` -> reverted.
- Ganache proof: `screenshots/08_compile.png`, `screenshots/08_test1.png`, `screenshots/08_test2.png`

## 09 Lottery
- What it does : fixed `0.01 ETH` fee lottery (`> 3` players required) where manager selects a winner to receive the full pot and resets the round.
- Key concept  : dynamic payable arrays, modulo selection via `blockhash(block.number - 1)`, CEI round reset (`delete players`) before payout.
- Tested       : 5 accounts enter `0.01 ETH`, `pickWinner()` emits `WinnerSelected` (`0.05 ETH`) and resets `playersCount()` to `0`; wrong fee, manager entry, and empty-round `pickWinner()` -> reverted.
- Ganache proof: `screenshots/09_compile.png`, `screenshots/09_test1.png`, `screenshots/09_test2.png`

## 10 TimeLockVault
- What it does : ETH time-lock vault locking deposits until `block.timestamp > unlockTime`, exclusively withdrawable by the designated beneficiary.
- Key concept  : timestamp gating (`require(block.timestamp > unlockTime)`), beneficiary-only `extendLock`, live countdown view (`timeRemaining()`).
- Tested       : deployed with `120s` lock, `deposit(1 ETH)`, immediate `withdraw()` -> reverted (`"Vault is still locked"`), after `+125s` Ganache time advance `timeRemaining() == 0` and `withdraw()` pays beneficiary `1 ETH`.
- Ganache proof: `screenshots/10_compile.png`, `screenshots/10_test1.png`, `screenshots/10_test2.png`

## 11 Escrow
- What it does : three-party (`buyer`, `seller`, `arbiter`) state-machine escrow handling delivery confirmation, voluntary refund, and dispute arbitration.
- Key concept  : `enum State` transitions enforced by `stateCheck(State)` modifier so terminal or frozen states reject invalid actions.
- Tested       : (1) normal `confirmDelivery()` -> `Complete (2)`; (2) `refundBuyer()` -> `Refunded (3)`; (3) `raiseDispute()` -> `confirmDelivery()` reverted -> `resolveToBuyer()` (`Refunded (3)`) & `resolveToSeller()` (`Complete (2)`).
- Ganache proof: `screenshots/11_compile.png`, `screenshots/11_test1.png`, `screenshots/11_test2.png`

## 12 SimpleNFT
- What it does : ERC-721 style NFT collection (`MAX_SUPPLY = 100`, `mintPrice = 0.01 ETH`) built from scratch with minting, approvals, and revenue withdrawal.
- Key concept  : sequential `tokenId` ownership (`ownerOf`), per-token approvals cleared on transfer, `onlyOwner` revenue extraction.
- Tested       : Account 1 mints `#0` and `#1`, transfers `#0` via `transferNFT()`, approves Account 2 on `#1` -> `transferFrom()` moves `#1` to Account 4, owner withdraws `0.02 ETH`; wrong mint price, self-approve, and stale-spender transfer -> reverted.
- Ganache proof: `screenshots/12_compile.png`, `screenshots/12_test1.png`, `screenshots/12_test2.png`

## 13 EnglishAuction
- What it does : timed auction enforcing a `5%` minimum bid increment (`MIN_INCREMENT`), pull-payment refunds for outbid bidders, and final settlement to seller.
- Key concept  : Pull-Payment (`pendingReturns`) pattern eliminating push-refund re-entrancy and DoS griefing inside `bid()`.
- Tested       : `startPrice = 0.1 ETH`, bids `0.11 ETH` -> `0.12 ETH`, outbid bidder `withdrawPending()` reclaims `0.11 ETH`, post-expiry `endAuction()` pays seller `0.12 ETH`; `< 5%` bid (`0.112 ETH`) & post-end bid -> reverted.
- Ganache proof: `screenshots/13_compile.png`, `screenshots/13_test1.png`, `screenshots/13_test2.png`

## 14 MultisigWallet
- What it does : M-of-N multi-signature treasury wallet requiring `required` owner confirmations before executing an ETH transfer once.
- Key concept  : owner whitelist (`isOwner`), per-transaction confirmation tracking (`confirmed[txId][owner]`), single-execution CEI (`txn.executed = true`).
- Tested       : 2-of-3 owners deployed & funded `2 ETH` via `receive()`, Account 0 `submitTransaction(1 ETH)` (`1/2`), Account 1 `confirmTransaction(0)` auto-executes (`2/2`, `+1 ETH` to recipient); re-confirm & non-owner submit -> reverted.
- Ganache proof: `screenshots/14_compile.png`, `screenshots/14_test1.png`, `screenshots/14_test2.png`

## 15 StakingRewards
- What it does : continuous per-second ETH staking contract distributing rewards (`wei` per `1 ETH` staked per second) from an owner-funded `rewardPool`.
- Key concept  : per-user `rewardDebt` checkpointing on multi-stake/claim, pool solvency bounds (`reward <= rewardPool`), atomic `unstake()` reset.
- Tested       : deployed (`rate = 1000 wei/s`, `5 ETH` pool), Account 1 stakes `1 ETH`, Account 2 stakes `2 ETH`, after `+60s` `pendingReward(A) == 60,000 wei`, A `claimReward()` keeps stake intact, B `unstake()` exits with principal+reward; double `unstake()` & non-owner `setRewardRate()` -> reverted.
- Ganache proof: `screenshots/15_compile.png`, `screenshots/15_test1.png`, `screenshots/15_test2.png`

---

## Required Design & Security Explanations

### 1. Contract 04 (`Ownable`) — Why Modifiers Save Code Duplication
Without a `modifier`, every privileged function (`transferOwnership`, `withdraw`, `pause`, `setFee`, etc.) must duplicate the identical `require(msg.sender == owner, "Not the owner");` check inside its body. If the ownership rule or error string changes later, every function across every derived contract must be edited manually—creating drift and missed checks. Defining `modifier onlyOwner()` once in the base contract [`Ownable`](../contracts/04_Ownable.sol#L18-L21) encapsulates the guard in a single source of truth that injects the check before `_;` cleanly across inherited contracts such as [`ProtectedVault`](../contracts/04_Ownable.sol#L39-L79).

### 2. Contract 05 (`SimpleBank`) — Checks-Effects-Interactions vs. Re-entrancy
In [`SimpleBank.withdraw`](../contracts/05_SimpleBank.sol#L27-L40), `.call{value: amount}("")` transfers control to `msg.sender`, which—if `msg.sender` is a malicious smart contract—can execute arbitrary fallback/`receive()` code and call `withdraw()` recursively before the outer call returns:
1. **Checks:** Verify `amount > 0` and `balances[msg.sender] >= amount`.
2. **Effects:** Deduct `balances[msg.sender] -= amount` *first* in storage.
3. **Interactions:** Execute `(bool success, ) = payable(msg.sender).call{value: amount}("")` last.

Because the internal ledger balance is already reduced before external control leaves the contract, any re-entrant `withdraw()` immediately hits `require(balances[msg.sender] >= amount, "Insufficient balance")` and reverts.

### 3. Contract 09 (`Lottery`) — Why `blockhash` Randomness Is Unsafe & Production Alternative
Using `uint256(blockhash(block.number - 1)) % players.length` in [`Lottery.pickWinner`](../contracts/09_Lottery.sol#L60-L74) is deterministic from on-chain state and unsuitable for real-money production lotteries:
- **Validator / Miner Manipulation:** A block proposer knows `blockhash(block.number - 1)` when building block `N`. An adversarial proposer who also entered the lottery can simulate `pickWinner()`, withhold the transaction until a favorable block hash appears, or skip proposing a block (paying only missed block rewards if the jackpot exceeds the block reward).
- **Front-running / Prediction:** Any public observer can read `blockhash(block.number - 1)` in the same slot before `pickWinner()` executes.
- **Production Alternative:** **Chainlink VRF (Verifiable Random Function)**, where an off-chain oracle generates randomness alongside a cryptographic zero-knowledge/elliptic-curve proof verified on-chain before triggering the callback, preventing both miners and the lottery manager from predicting or biasing the outcome.

### 4. Contract 13 (`EnglishAuction`) — Pull-Payment (`pendingReturns`) vs. Push-Payment (Contract 05)
In [`EnglishAuction.bid`](../contracts/13_EnglishAuction.sol#L37-L54), an incoming higher bid does **not** directly send ETH back to the previous `highestBidder`. Instead, it credits `pendingReturns[previousBidder] += previousBid`, requiring the outbid user to reclaim funds separately via [`withdrawPending()`](../contracts/13_EnglishAuction.sol#L59-L74):
- **Why Push Inside `bid()` Breaks:** If `bid()` pushed ETH synchronously to the previous leader (`previousBidder.call{value: previousBid}("")`), a malicious bidder contract could deploy with a reverting `receive()` fallback—causing every subsequent higher bid to revert (permanent Denial-of-Service griefing to steal the auction cheaply) or attempt cross-function re-entrancy during bidding.
- **Comparison with Contract 05 (`SimpleBank`):** Both `SimpleBank.withdraw()` and `EnglishAuction.withdrawPending()` use user-initiated withdrawals guarded by **Checks-Effects-Interactions** (state deduction/zeroing prior to `.call`). The architectural distinction is that `SimpleBank` tracks independent per-user deposits with no multi-user action coupling, whereas `EnglishAuction` deliberately decouples the competitive multi-party state transition (`bid()`) from individual ETH settlement (`withdrawPending()`), isolating failure or malice of one participant from blocking all others.

---

## Known Limitations & Design Trade-offs Noted During Audit
- **Contract 09 (`Lottery`):** `pickWinner()` pushes the prize directly to `winner`; if a smart-contract player rejects incoming ETH transfers, `require(success)` reverts the draw for all participants (mitigated in production by pull-claiming prizes).
- **Contract 12 (`SimpleNFT`):** [`approve()`](../contracts/12_SimpleNFT.sol#L74-L81) rejects `spender == address(0)`, preventing direct zero-address approval revocation unless overridden or transferred; deliberate choice per explicit non-zero guard.
- **Contract 15 (`StakingRewards`):**
  - [`unstake()`](../contracts/15_StakingRewards.sol#L80-L98) requires `reward <= rewardPool`, blocking principal withdrawal if the owner underfunds rewards (intentional spec guard to enforce reward solvency; production systems typically add an emergency principal-only withdraw path).
  - [`setRewardRate()`](../contracts/15_StakingRewards.sol#L134-L137) updates `rewardRatePerSecond` globally without checkpointing a cumulative reward-per-token accumulator, meaning active stakers earn at the updated rate since their last `startTime` unless the owner snapshots before changing rates.
- **Ganache / Remix EVM Compatibility:** Solidity `>= 0.8.25` emits `MCOPY` (`0x5e`) under default `cancun`/`osaka` EVM targets, whereas Ganache v7 / GUI executes up to the `shanghai` hardfork. All 15 contracts were compiled and verified under `--evm-version shanghai` (`0` errors, `0` warnings).
