# AgentMint — SPEC

## Concept
A free mint for Agent ID holders on BNB Chain. One ERC-721 per wallet, price 0
(minters pay gas only). The contract checks on-chain that the minter holds an
Agent ID (SPACE ID Agent ID, `0x60B9262456dE011F7d15a54cdd8c48baaa8b022f`, BSC
mainnet). Supply is capped at 1000. Metadata is generated fully on-chain
(SVG + JSON data URI) — no external hosting, no IPFS dependency.

- Project name: **AgentMint**
- Token: **AgentMint** (symbol `AMINT`), ERC-721
- Chain: BNB Chain mainnet (chain ID 56)
- Price: 0. One mint per wallet. Supply 1000.

## Why it fits the hackathon scoring
- **Agent ID Application Depth (30%)** — Agent ID is the core access control:
  `mint()` reverts unless `agentId.balanceOf(msg.sender) > 0`. Without an Agent
  ID the product does nothing. This is the "access control" use case the
  hackathon asks for.
- **Practicality & Feasibility (25%)** — Free mints are a real, proven behavior
  in the Agent ID ecosystem (Agent ID holders already hunt free mints). The
  contract is small, audited-pattern (OpenZeppelin ERC-721), and the whole
  product is one contract + one static page.
- **Product Completion (25%)** — Contract is written, fork-tested against the
  real Agent ID contract, and the frontend is a working static site (connect,
  check eligibility, mint, supply, BscScan links). Deploy + verify is the only
  remaining step before it is live.
- **Innovation (20%)** — Honest assessment: a gated free mint is not a novel
  primitive. The differentiation is that it is the first mint gated purely by
  Agent ID holding (no allowlist, no snapshot, no off-chain list) with zero
  owner power and fully on-chain metadata. Innovation is the weakest dimension;
  the entry competes on depth + completion, not novelty.

## Contract design (`src/AgentMint.sol`)
- `AgentMint is ERC721` (OpenZeppelin v5.7.0). Solidity ^0.8.20.
- Immutable: `agentId` (the Agent ID contract), `maxSupply` (1000).
- `mint() payable`: reverts `NonZeroValue` if `msg.value != 0`,
  `NotAgentIDHolder` if `agentId.balanceOf(msg.sender) == 0`,
  `AlreadyMinted` if the wallet minted before, `SoldOut` at 1000.
  Token IDs are sequential from 1.
- `remaining()`, `hasMinted(address)`, `totalMinted()` are public views.
- `tokenURI(tokenId)`: fully on-chain JSON data URI with an embedded SVG
  (name, "AGENTMINT #N", "FREE MINT FOR AGENT ID HOLDERS", "PRICE 0 — GAS
  ONLY"). Verified to decode to valid JSON + valid SVG.
- **No owner, no admin, no upgradeability.** There is no `Ownable`, no
  `setBaseURI`, no pause, no withdraw — the contract can never hold or move
  user funds (mint requires `msg.value == 0`). Nothing about supply, price,
  gating, or metadata can ever change after deployment.

## Frontend flow (`frontend/index.html`, static, no build step)
1. User opens the page and clicks "Connect wallet" — uses the injected
   `window.ethereum` provider only (Binance Wallet / MetaMask in-browser).
   No QR-code login, no pairing code, no server, no session storage.
2. Page reads `balanceOf` on the Agent ID contract for the connected wallet
   and shows whether it holds an Agent ID.
3. Page reads `totalMinted` / `maxSupply` / `hasMinted` from the AgentMint
   contract and shows supply + the user's mint status.
4. Eligible users click "Mint" — the transaction is sent with value 0 and the
   user confirms it in their own wallet. Nothing is ever signed or sent
   without the user's explicit confirmation in the wallet.
5. Success shows the transaction hash with a BscScan link.

## Gas (measured on a BSC mainnet fork, 2026-11-19)
- Deployment: **2,731,618 gas**
  - low (~0.0552 gwei): **0.000151 BNB**
  - medium (~0.0675 gwei): **0.000184 BNB**
  - high (~0.1432 gwei): **0.000391 BNB**
- First mint: **122,548 gas** (~0.000008 BNB at medium)
- Alesha's wallet balance: **0.000088 BNB — NOT enough to deploy even at low
  gas** (shortfall ~0.000063 BNB at low, ~0.000096 BNB at medium).
  Recommended: top up to ~0.000243 BNB total (deploy at medium + 1 mint +
  buffer); shortfall ~0.000155 BNB. **No deployment until the funding
  decision is made.**

## Timeline to 9 Dec 2026 15:00 WIB (submission deadline)
- 19 Nov: contract + tests + frontend done (this spec).
- 20–21 Nov: funding decision (top up ~0.00016 BNB), deploy to BSC mainnet,
  verify source on BscScan, fill the contract address into the frontend,
  host the frontend (GitHub Pages).
- 22 Nov–9 Dec: promotion to Agent ID holders (Threads/X, Agent ID
  communities) to reach the **30 interacting Agent ID addresses** required
  for the Innovation Award; submit project (name, website, contract address,
  Agent ID usage description) before 9 Dec 15:00 WIB.
- 9–17 Dec: internal review. 17–20 Dec: public review.

## Risks (honest)
1. **30 Agent ID interactions** — the biggest risk. A free mint is the most
   plausible draw, but 30 distinct Agent ID holders must actually mint. This
   depends on promotion, not on code.
2. **Ecosystem Growth Award is a volume race** — ranked by interacting
   addresses + tx volume; a solo newcomer is unlikely to outrank established
   projects. The realistic target is the **Innovation Award** (judged, not
   volume-ranked).
3. **Funding** — deployment needs ~0.00016 BNB more than the wallet holds.
   Small in absolute terms, but a hard blocker until topped up.
4. **Innovation score** — the concept is simple by design; the panel may
   score novelty low. Mitigated by depth (Agent ID is the whole gate) and
   completion (live, tested, verified).
