// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AgentMint.sol";

/// @notice Deploy AgentMint to BSC mainnet.
///         Dry-run: forge script script/Deploy.s.sol --fork-url <bsc-rpc-url>
///         Real deploy (only with alesha's explicit approval + funded wallet):
///         forge script script/Deploy.s.sol --rpc-url <bsc-rpc-url> --broadcast --private-key <key>
contract Deploy is Script {
    address constant AGENT_ID = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    function run() external returns (AgentMint) {
        vm.startBroadcast();
        AgentMint mint = new AgentMint(AGENT_ID, 1000);
        vm.stopBroadcast();
        return mint;
    }
}
