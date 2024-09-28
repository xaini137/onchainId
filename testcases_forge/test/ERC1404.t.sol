// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Proton} from "../src/ERC1404/updated1404_flattened.sol";
import {TransferRestrictions} from "../src/ERC1404/Restriction/restriction_flatten.sol"; // Assuming you have this contract

contract ProtonTest is Test {
    Proton proton;
    TransferRestrictions transferRestrictions;
    address admin = address(1);
    address pauser = address(2);
    address minter = address(3);
    address registrar = address(4);
    address whitelister = address(5);
    address user1 = address(6);
    address user2 = address(7);
    address user3 = address(8);
    address user4 = address(9);

    function setUp() public {
        // Deploy contracts
        proton = new Proton(admin, pauser, minter, registrar, whitelister);
        transferRestrictions = new TransferRestrictions(address(proton));
        // Update transfer restrictions
        vm.prank(admin);
        proton.updateTransferRestrictions(address(transferRestrictions));
        // Mint tokens to user1
        vm.prank(minter);
        proton.mint(user1, 1000);
        // Register user1
        vm.prank(registrar);
        proton.register(user1, "NonUS");
    }

    function testCannotTransferWithoutRegistration() public {
        vm.prank(user1);
        vm.expectRevert(
            "The transfer was restricted due to white list configuration."
        );
        proton.transfer(user2, 100);
    }

    function testCanReceiveWithoutRegistration() public {
        vm.startPrank(whitelister);
        proton.setWhitelist(user1, true, "");
        vm.stopPrank();
        vm.prank(user1);
        proton.transfer(user2, 100);
        assertEq(
            proton.balanceOf(user2),
            100,
            "User2 should receive tokens without registration"
        );
    }

    function testCanTransferAfterRegistration() public {
        vm.startPrank(whitelister);
        proton.setWhitelist(user1, true, "");
        proton.setWhitelist(user2, true, "");
        vm.stopPrank();
        vm.prank(registrar);
        proton.register(user2, "NonUS");
        vm.prank(user1);
        proton.transfer(user2, 100);
        assertEq(
            proton.balanceOf(user2),
            100,
            "User2 should receive tokens after registration"
        );
    }

    function testAdminRoleChecker() public view {
        assertTrue(
            proton.hasRole(proton.DEFAULT_ADMIN_ROLE(), admin),
            "Admin should have DEFAULT_ADMIN_ROLE"
        );
        assertFalse(
            proton.hasRole(proton.DEFAULT_ADMIN_ROLE(), user1),
            "User1 should not have DEFAULT_ADMIN_ROLE"
        );
    }

    function testOnlyAdminCanAddRole() public {
        bytes32 MINTER_ROLE = keccak256("MINTER_ROLE");
        bytes32 WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");
        vm.startPrank(admin);
        proton.grantRole(MINTER_ROLE, user1);
        assertTrue(
            proton.hasRole(MINTER_ROLE, user1),
            "User1 should have the MINTER_ROLE"
        );
        proton.grantRole(WHITELISTER_ROLE, user2);
        assertTrue(
            proton.hasRole(WHITELISTER_ROLE, user2),
            "User2 should have the WHITELISTER_ROLE"
        );
        vm.stopPrank();
    }

    function testOnlyMinterCanMint() public {
        bytes32 MINTER_ROLE = keccak256("MINTER_ROLE");
        vm.prank(admin);
        proton.grantRole(MINTER_ROLE, user1);
        // User1 (minter) can mint
        vm.prank(user1);
        proton.mint(user2, 1000);
        assertEq(
            proton.balanceOf(user2),
            1000,
            "User2 should receive minted tokens"
        );
        // User2 (non-minter) cannot mint
        vm.prank(user2);
        // Expect a revert with AccessControlUnauthorizedAccount error

        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)",
                user2,
                MINTER_ROLE
            )
        );
        proton.mint(user3, 1000);
    }

    function testOnlyWhitelisterCanWhitelist() public {
        bytes32 WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");

        // Grant WHITELISTER_ROLE to user1
        vm.prank(admin);
        proton.grantRole(WHITELISTER_ROLE, user1);

        // User1 (whitelister) can whitelist user2
        vm.prank(user1);
        proton.setWhitelist(user2, true, "Whitelisted");
        assertTrue(
            proton.getWhitelistStatus(user2),
            "User2 should be whitelisted"
        );

        // User3 (non-whitelister) cannot whitelist user4
        vm.prank(user3);

        // Expect a revert due to missing WHITELISTER_ROLE
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)",
                user3,
                WHITELISTER_ROLE
            )
        );
        proton.setWhitelist(user4, true, "Attempt to whitelist");
    }

    function testOnlyRegistrarCanRegister() public {
        bytes32 USER_REGISTRAR_ROLE = keccak256("USER_REGISTRAR_ROLE");

        // Grant USER_REGISTRAR_ROLE to user1
        vm.prank(admin);
        proton.grantRole(USER_REGISTRAR_ROLE, user1);

        // User1 (registrar) can register user2
        vm.prank(user1);
        proton.register(user2, "NonUS");
        assertTrue(proton.isRegistered(user2), "User2 should be registered");

        // User3 (non-registrar) cannot register user4
        vm.prank(user3);

        // Expect a revert due to missing USER_REGISTRAR_ROLE
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)",
                user3,
                USER_REGISTRAR_ROLE
            )
        );
        proton.register(user4, "NonUS");
    }

    function testOnlyPauserCanPauseAndUnpause() public {
        bytes32 PAUSER_ROLE = keccak256("PAUSER_ROLE");

        // Grant PAUSER_ROLE to user1
        vm.prank(admin);
        proton.grantRole(PAUSER_ROLE, user1);

        // User1 (pauser) can pause the contract
        vm.prank(user1);
        proton.pause();
        assertTrue(proton.paused(), "Contract should be paused");

        // User2 (non-pauser) cannot unpause the contract
        vm.prank(user2);

        // Expect a revert due to missing PAUSER_ROLE
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)",
                user2,
                PAUSER_ROLE
            )
        );
        proton.unpause();

        // User1 (pauser) can unpause the contract
        vm.prank(user1);
        proton.unpause();
        assertFalse(proton.paused(), "Contract should be unpaused");
    }

    function testOnlyRevokerCanRevoke() public {
        bytes32 DEFAULT_ADMIN_ROLE = proton.DEFAULT_ADMIN_ROLE();
        address userToRevoke = address(10);
        address nonAdmin = address(11);
        vm.prank(minter);
        proton.mint(userToRevoke,1);
        // Test: Admin can revoke
        vm.prank(admin);
        proton.revoke(userToRevoke,1);
        assertEq(proton.balanceOf(userToRevoke),0);

        // Test: Non-admin cannot revoke
        vm.prank(nonAdmin);
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)",
                nonAdmin,
                DEFAULT_ADMIN_ROLE
            )
        );
        proton.revoke(address(12),1);
    }
    
}
