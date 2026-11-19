// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AgentMint.sol";

/// @notice Fork tests against BSC mainnet: the Agent ID gating is tested against the
///         REAL Agent ID contract (0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F).
///         Run with: forge test --fork-url <bsc-rpc-url> -vv
contract AgentMintTest is Test {
    AgentMint public mint;

    address constant AGENT_ID = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;
    address constant ALESHA = 0x6d5fafC7115E047C6f4684263d2B5Fda4b0100A2;

    function setUp() public {
        mint = new AgentMint(AGENT_ID, 1000);
    }

    function test_AleshaCanMint() public {
        // Sanity: alesha (adhais23.ai) holds an Agent ID on the fork.
        assertGt(IAgentID(AGENT_ID).balanceOf(ALESHA), 0);

        vm.prank(ALESHA);
        mint.mint();

        assertEq(mint.balanceOf(ALESHA), 1);
        assertEq(mint.ownerOf(1), ALESHA);
        assertEq(mint.totalMinted(), 1);
        assertTrue(mint.hasMinted(ALESHA));
        assertEq(mint.remaining(), 999);

        // tokenURI is a non-empty on-chain data URI.
        string memory uri = mint.tokenURI(1);
        assertGt(bytes(uri).length, 100);
        assertEq(bytes(uri)[0], bytes("d")[0]); // "data:application/json;base64,..."
    }

    function test_Revert_NoAgentID() public {
        address nobody = address(0x1234);
        assertEq(IAgentID(AGENT_ID).balanceOf(nobody), 0);

        vm.prank(nobody);
        vm.expectRevert(AgentMint.NotAgentIDHolder.selector);
        mint.mint();
    }

    function test_Revert_SecondMint() public {
        vm.prank(ALESHA);
        mint.mint();

        vm.prank(ALESHA);
        vm.expectRevert(AgentMint.AlreadyMinted.selector);
        mint.mint();
    }

    function test_Revert_NonZeroValue() public {
        // Fund the pranked wallet first: without it the call reverts OutOfFunds
        // before the contract's NonZeroValue check (alesha's real BNB is tiny).
        vm.deal(ALESHA, 1 ether);
        vm.prank(ALESHA);
        vm.expectRevert(AgentMint.NonZeroValue.selector);
        mint.mint{value: 0.001 ether}();
    }

    function test_Revert_SoldOut() public {
        // Small-supply instance (2) to test the cap without 1000 mints.
        // Holders are real Agent ID holders: recipients of Agent ID mints in recent
        // blocks (read from live Transfer events). Agent ID is non-transferable,
        // so they still hold it; asserted below.
        AgentMint small = new AgentMint(AGENT_ID, 2);
        address h1 = 0x4Aa7B94569A2f9f7f8db66e6168DdB98ed9AFE0C;
        address h2 = 0x49917A3b9Bb8b0BeB6DD0Ebf66d185B971Dc65c0;
        address h3 = 0x2396342A94Ff9a17f41235BeBbF7E02637318D8E;
        assertGt(IAgentID(AGENT_ID).balanceOf(h1), 0);
        assertGt(IAgentID(AGENT_ID).balanceOf(h2), 0);
        assertGt(IAgentID(AGENT_ID).balanceOf(h3), 0);

        vm.prank(h1);
        small.mint();
        vm.prank(h2);
        small.mint();

        assertEq(small.totalMinted(), 2);
        assertEq(small.remaining(), 0);

        vm.prank(h3);
        vm.expectRevert(AgentMint.SoldOut.selector);
        small.mint();
    }

    function test_TokenURI_RevertsForNonexistent() public {
        vm.expectRevert();
        mint.tokenURI(999);
    }
}
