// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title AgentMint — a free mint for Agent ID holders
/// @notice One free ERC-721 per Agent ID holder. Price is 0; minters pay gas only.
/// @dev Gating reads balanceOf() on the SPACE ID Agent ID contract
///      (0x60b9262456de011f7d15a54cdd8c48baaa8b022f, BSC mainnet, ERC-721, non-transferable).
///      There is NO owner and NO admin: no function can change supply, price, gating,
///      or metadata, and the contract can never hold or move user funds (mint requires
///      msg.value == 0). Metadata is generated fully on-chain (SVG + JSON data URI).
contract AgentMint is ERC721 {
    using Strings for uint256;

    IAgentID public immutable agentId;
    uint256 public immutable maxSupply;
    uint256 public totalMinted;

    mapping(address => bool) public hasMinted;

    error NotAgentIDHolder();
    error AlreadyMinted();
    error SoldOut();
    error NonZeroValue();

    /// @param agentIdContract The SPACE ID Agent ID contract on BSC mainnet.
    /// @param maxSupply_ Total supply cap (1000 for the production deployment).
    constructor(address agentIdContract, uint256 maxSupply_) ERC721("AgentMint", "AMINT") {
        agentId = IAgentID(agentIdContract);
        maxSupply = maxSupply_;
    }

    /// @notice Mint one free token. Caller must hold an Agent ID and must not have minted before.
    function mint() external payable {
        if (msg.value != 0) revert NonZeroValue();
        if (agentId.balanceOf(msg.sender) == 0) revert NotAgentIDHolder();
        if (hasMinted[msg.sender]) revert AlreadyMinted();
        if (totalMinted >= maxSupply) revert SoldOut();

        hasMinted[msg.sender] = true;
        unchecked {
            totalMinted += 1;
        }
        _safeMint(msg.sender, totalMinted);
    }

    /// @notice How many mints are left.
    function remaining() external view returns (uint256) {
        return maxSupply - totalMinted;
    }

    /// @notice Fully on-chain metadata: JSON data URI with an embedded SVG image.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">',
                '<rect width="512" height="512" fill="#0b0e11"/>',
                '<rect x="24" y="24" width="464" height="464" fill="none" stroke="#f0b90b" stroke-width="6"/>',
                '<text x="256" y="150" font-family="monospace" font-size="52" font-weight="bold" fill="#f0b90b" text-anchor="middle">AGENTMINT</text>',
                '<text x="256" y="240" font-family="monospace" font-size="96" font-weight="bold" fill="#ffffff" text-anchor="middle">#',
                tokenId.toString(),
                "</text>",
                '<text x="256" y="320" font-family="monospace" font-size="28" fill="#848e9c" text-anchor="middle">FREE MINT FOR</text>',
                '<text x="256" y="360" font-family="monospace" font-size="28" fill="#848e9c" text-anchor="middle">AGENT ID HOLDERS</text>',
                '<text x="256" y="440" font-family="monospace" font-size="20" fill="#5e6673" text-anchor="middle">PRICE 0 - GAS ONLY</text>',
                "</svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"AgentMint #',
                        tokenId.toString(),
                        '","description":"A free mint for Agent ID holders on BNB Chain. One per Agent ID holder, price 0 (gas only). Built for the Binance Agent ID Hackathon.","image":"data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '","attributes":[{"trait_type":"Collection","value":"AgentMint"},{"trait_type":"Gate","value":"Agent ID"}]}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
