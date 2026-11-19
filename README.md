# AgentMint — Free Mint for Agent ID Holders

**Agent ID Hackathon** (Binance Wallet + BNB Chain). Submission period ends
2026-12-09 08:00 UTC (9 Dec 2026 15:00 WIB).

AgentMint is a free ERC-721 mint for Agent ID holders on BNB Chain. One token
per wallet, price 0 (minters pay gas only). The contract checks on-chain that
the minter holds an Agent ID. Supply 1000. Metadata is fully on-chain.

- Contract: `src/AgentMint.sol` (Solidity ^0.8.20, OpenZeppelin v5.7.0)
- Tests: `test/AgentMint.t.sol` (Foundry fork tests vs the real Agent ID contract)
- Frontend: `frontend/index.html` (static site, no build step)
- Spec: `SPEC.md`

## Build & test

```bash
export PATH="$HOME/.foundry/bin:$PATH"
# Install dependencies (OpenZeppelin v5.7.0 + forge-std) — not vendored in this repo:
forge install foundry-rs/forge-std
forge install OpenZeppelin/openzeppelin-contracts@v5.7.0
forge build
forge test --fork-url https://bsc-rpc.publicnode.com --match-contract AgentMintTest
```

All 6 fork tests pass (verified 2026-11-19):

| Test | Result |
|---|---|
| `test_AleshaCanMint` — alesha's wallet (adhais23.ai) mints | PASS |
| `test_Revert_NoAgentID` — address without Agent ID reverts | PASS |
| `test_Revert_SecondMint` — second mint from same wallet reverts | PASS |
| `test_Revert_NonZeroValue` — mint with msg.value > 0 reverts | PASS |
| `test_Revert_SoldOut` — mint past supply cap reverts | PASS |
| `test_TokenURI_RevertsForNonexistent` — tokenURI(999) reverts | PASS |

## Deployed (live on BNB Chain, 19 Nov 2026)

- **Contract:** [`0x038Cb9B125915087FD980F995575CA105dDC9e6e`](https://bscscan.com/address/0x038Cb9B125915087FD980F995575CA105dDC9e6e) (AgentMint / AMINT)
- **Deploy tx:** [`0x7bf36e3972dec91f20d55aed79ece8d283c300ada139cddc4ebee5e4de4959fc`](https://bscscan.com/tx/0x7bf36e3972dec91f20d55aed79ece8d283c300ada139cddc4ebee5e4de4959fc), block 134473431, status success
- **Gas used:** 2,702,212 (~0.000186 BNB)
- **Source verified** on BscScan ("Contract Source Code Verified (Exact Match)") and Sourcify (exact match)
- **Live state (verified on-chain):** name AgentMint, symbol AMINT, totalMinted 0, remaining 1000, Agent ID gate points at `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`
- **Mint page:** https://adhais23.github.io/agentmint/ (frontend/index.html, `MINT_CONTRACT` filled)

```bash
# Dry-run on a BSC fork (no funds spent):
forge script script/Deploy.s.sol --fork-url https://bsc-rpc.publicnode.com

# The real deploy was done via the EIP-2470 factory (CREATE2) because the
# Agentic Wallet holds the key — direct forge --broadcast needs a private
# key nobody has. See deploy/ for the init code and deploy calldata.
```

## Owner permissions

**There is no owner and no admin.** The contract has no `Ownable`, no pause,
no `setBaseURI`, no withdraw, no upgradeability. Nothing can change supply,
price, gating, or metadata after deployment, and the contract can never hold
or move user funds (`mint()` requires `msg.value == 0`).

## Hackathon compliance checklist

| # | Red line (hackathon rules) | How AgentMint complies |
|---|---|---|
| 1 | No web-based QR-code login for Agentic Wallet; no pairing codes on third-party sites; no storing login sessions on servers | Frontend uses only the injected `window.ethereum` provider (in-browser wallet). No QR, no pairing code, no server at all (static site), nothing stored anywhere. |
| 2 | Skills/prompts must not bypass user transaction confirmation | The frontend only proposes the mint transaction; the user confirms it in their own wallet. Nothing is sent without that confirmation. |
| 3 | No unauthorized asset transfers (no scheduled collection, auto-transfers, bundled extra transfers, unlimited approvals) | The contract has no transfer, withdraw, or approval function of any kind. Minting moves nothing except the newly minted NFT to the minter. |
| 4 | Contracts must be open-source with disclosed owner permissions | Source is public (this repo) and verified on BscScan (exact match) + Sourcify. Owner permissions: none exist (see above). |
| 5 | No impersonation of the Binance brand (names, tokens, domains must not use "Binance"/"BNB") | Project/token name is "AgentMint" — no "Binance", no "BNB" anywhere in the contract, metadata, or frontend. |
| 6 | No collection of seed phrases, private keys, API secrets, or pairing codes | Nothing is ever asked for or collected. The frontend only reads the connected wallet address and public on-chain state. |
| 7 | Must not promise returns ("passive income", "automatic money-making") | No returns are promised anywhere — contract, metadata, or frontend. The token is a free collectible for Agent ID holders. |
| 8 | Agent ID must not be packaged as a tool for "looking up other people's wallets by name" | Agent ID is used only as **access control**: `mint()` checks `balanceOf(msg.sender) > 0` on the Agent ID contract. There is no name lookup, no directory, no way to query anyone else's wallet by name. |

## Links
- Hackathon announcement: https://www.binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf
- Agent ID contract (BSC): https://bscscan.com/address/0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F
