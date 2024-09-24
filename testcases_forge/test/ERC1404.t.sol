// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proton} from "../src/ERC1404/ERC1404_flatten.sol";
import {TransferRestrictions} from "../src/ERC1404/Restriction/restriction_flatten.sol";

contract ProtonTest is Test {
    Proton public proton;
    TransferRestrictions public transferRestrictions;
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public user5;
    address public user6;

// initialize the contract (proton and transferRestrictions)
    function setUp() public {
        proton = new Proton();
        // Pass the Proton contract address to the TransferRestrictions constructor
        transferRestrictions = new TransferRestrictions(address(proton));
       proton.updateTransferRestrictions(address(transferRestrictions));
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        user3 = address(0x3);
        user4 = address(0x4);
        user5 = address(0x5);
        user6 = address(0x6);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
        vm.deal(user4, 100 ether);
        vm.deal(user5, 100 ether);
        vm.deal(user6, 100 ether);
    }
// test if the owner is the owner
    function test_Owner() public {
        assertEq(proton.isOwner(owner), true);   
        assertEq(proton.isOwner(user1), false);  
        assertEq(proton.isOwner(user2), false);  
        assertEq(proton.isOwner(user3), false); 
    }

// test if the owner can add and remove owner
    function test_add_remove_Owner() public {
        proton.addOwner(user1);
        assertEq(proton.isOwner(user1), true);
        proton.removeOwner(user1);
        assertEq(proton.isOwner(user1), false);
        proton.addPauser(user4);
        assertEq(proton.isPauser(user4), true);
        proton.addRevoker(user5);
        assertEq(proton.isRevoker(user5), true);
        proton.addWhitelister(user6);
        assertEq(proton.isWhitelister(user6), true);
    }

// test if the caller is not the owner
    function test_caller_not_owner() public {
        vm.prank(user1); 
        vm.expectRevert("OwnerRole: caller does not have the Owner role");
        proton.addOwner(user2); 
    }

    // Token transfer checks without whitelisting
    function test_token_transfer_checks() public {
        vm.prank(user1);
         vm.expectRevert("The transfer was restricted due to no user type assigned");
        proton.transfer(user2, 1 ether); // Adjust this based on your transfer logic
    
    }

    // Token transfer checks with whitelisting and added user type
function test_token_transfer_checks_with_whitelisting() public {
    vm.prank(owner); 
    proton.addWhitelister(owner);
     proton.setWhitelist(owner, true, 'NonUS');
    proton.register(owner, 'NonUS');
  proton.addWhitelister(user2); 
    proton.setWhitelist(user2, true, 'NonUS');
    proton.register(user2, 'NonUS');
    proton.transfer(user2, 1 ether);
// vm.expectRevert("The transfer was restricted due to no user type assigned");
   vm.expectRevert("The transfer was restricted due to white list configuration.");
    proton.transfer(user1, 1 ether);
}

}
