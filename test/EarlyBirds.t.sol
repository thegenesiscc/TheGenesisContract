// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {EarlyBirds} from "../src/EarlyBirdsContract/EarlyBirds.sol";

error OwnableUnauthorizedAccount(address account);

contract EarlyBirdsTest is Test {
    EarlyBirds public earlyBirds;
    address public owner;
    address public treasury;
    address public user1;
    address public user2;
    address public user3;

    // Setup test environment
    function setUp() public {
        owner = address(1);
        treasury = address(2);
        user1 = address(3);
        user2 = address(4);
        user3 = address(5);
        
        vm.prank(owner);
        earlyBirds = new EarlyBirds(owner, treasury);
    }

    // Test normal registration
    function testRegisterSuccess() public {

        vm.prank(owner);
        earlyBirds.startActivity();
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        earlyBirds.register{value: 0.01 ether}();

        assertTrue(earlyBirds.isRegistered(user1));
        assertEq(treasury.balance, 0.01 ether);
    }

     // Test registration when activity is not active
    function testRegisterWhenNotActive() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectRevert("Activity is not active");
        earlyBirds.register{value: 0.01 ether}();
    }

    // Test registration with incorrect fee
    function testRegisterWithIncorrectFee() public {
        vm.prank(owner);
        earlyBirds.startActivity();

        vm.deal(user1, 1 ether);
        vm.prank(user1);
        vm.expectRevert("Incorrect registration fee");
        earlyBirds.register{value: 0.02 ether}();
    }

    // Test duplicate registration
    function testRegisterDuplicate() public {
        vm.prank(owner);
        earlyBirds.startActivity();

        vm.deal(user1, 2 ether);
        vm.startPrank(user1);
        earlyBirds.register{value: 0.01 ether}();
        
        vm.expectRevert("Already registered");
        earlyBirds.register{value: 0.01 ether}();
        vm.stopPrank();
    }

    // Test admin registration - normal case
    function testRegisterByAdminSuccess() public {
        address[] memory addresses = new address[](2);
        addresses[0] = user1;
        addresses[1] = user2;

        vm.prank(owner);
        earlyBirds.registerByAdmin(addresses);

        assertTrue(earlyBirds.isRegistered(user1));
        assertTrue(earlyBirds.isRegistered(user2));
    }

    // Test admin registration - non-admin call
    function testRegisterByAdminNotOwner() public {
        address[] memory addresses = new address[](1);
        addresses[0] = user1;

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, user1)
        );
        earlyBirds.registerByAdmin(addresses);
    }

    // Test admin registration - duplicate address
    function testRegisterByAdminDuplicate() public {
        // Register one address first
        address[] memory addresses1 = new address[](1);
        addresses1[0] = user1;
        vm.prank(owner);
        earlyBirds.registerByAdmin(addresses1);

        // Try to register the same address again
        address[] memory addresses2 = new address[](2);
        addresses2[0] = user2;
        addresses2[1] = user1;  // Duplicate address

        vm.prank(owner);
        vm.expectRevert("Already registered");
        earlyBirds.registerByAdmin(addresses2);
    }

    // Test participant list retrieval
    function testGetParticipantList() public {
        // Add two participants through admin
        address[] memory addresses = new address[](2);
        addresses[0] = user1;
        addresses[1] = user2;

        vm.prank(owner);
        earlyBirds.registerByAdmin(addresses);

        // Get participant list and verify
        address[] memory participants = earlyBirds.getParticipantList();
        assertEq(participants.length, 2);
        assertEq(participants[0], user1);
        assertEq(participants[1], user2);
    }
} 