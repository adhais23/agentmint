// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/AgentMint.sol";

/// @notice Measures exact gas for deploy + first mint on a BSC fork. Read-only simulation.
contract GasReport is Script {
    address constant AGENT_ID = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;
    address constant ALESHA = 0x6d5fafC7115E047C6f4684263d2B5Fda4b0100A2;

    function run() external {
        uint256 g0 = gasleft();
        AgentMint mint = new AgentMint(AGENT_ID, 1000);
        uint256 g1 = gasleft();
        vm.startPrank(ALESHA);
        mint.mint();
        uint256 g2 = gasleft();
        vm.stopPrank();

        console.log("deploy gas:", g0 - g1);
        console.log("first mint gas:", g1 - g2);
        console.log("minted token 1 to alesha, totalMinted:", mint.totalMinted());
    }
}
