// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/EarlyBirdsContract/EarlyBirds.sol";

contract EarlyBirdsTest is Test {
    EarlyBirds earlyBirds;
    address owner;
    address participant1;
    address participant2;

    function setUp() public {
        owner = address(this); // The deployer is the test contract itself
        // Deploy the EarlyBirds contract
        earlyBirds = new EarlyBirds(owner);
        participant1 = address(0x1);
        participant2 = address(0x2);

        // Fund participant1 with enough BNB for registration
        vm.deal(participant1, 0.1 ether); // Give participant1 0.1 BNB
    }

    function testInitialState() public view {
        assertEq(earlyBirds.isActive(), false, "Activity should be inactive initially");
        assertEq(earlyBirds.getParticipantList().length, 0, "Participant list should be empty initially");
    }

    function testStartActivity() public {
        // Start the activity
        vm.prank(owner);
        earlyBirds.startActivity();
        assertEq(earlyBirds.isActive(), true, "Activity should be active after starting");
    }

    function testPauseActivity() public {
        // Start and then pause the activity
        vm.prank(owner);
        earlyBirds.startActivity();
        vm.prank(owner);
        earlyBirds.pauseActivity();
        assertEq(earlyBirds.isActive(), false, "Activity should be inactive after pausing");
    }

    function testRegister() public {
        // Start the activity
        vm.prank(owner);
        earlyBirds.startActivity();

        // Check if the activity is active
        assertEq(earlyBirds.isActive(), true, "Activity should be active before registration");

        // Check if participant1 is already registered
        assertEq(earlyBirds.isRegistered(participant1), false, "Participant1 should not be registered yet");

        // Register participant1
        vm.prank(participant1);
        earlyBirds.register{value: 0.01 ether}();

        // Check if participant1 is now registered
        assertEq(earlyBirds.isRegistered(participant1), true, "Participant1 should be registered");
        assertEq(earlyBirds.getParticipantList().length, 1, "Participant list should contain one participant");
    }

    function testRegisterTwice() public {
        // Start the activity
        vm.prank(owner);
        earlyBirds.startActivity();

        // Register participant1
        vm.prank(participant1);
        earlyBirds.register{value: 0.01 ether}();

        // Attempt to register again
        vm.prank(participant1);
        vm.expectRevert("Already registered");
        earlyBirds.register{value: 0.01 ether}();
    }

    function testMaxParticipants() public {
        // Start the activity
        vm.prank(owner);
        earlyBirds.startActivity();

        // Register maximum participants
        for (uint256 i = 0; i < 2000; i++) {
            address participant = address(uint160(i + 3)); // Create unique addresses
            vm.deal(participant, 0.1 ether); 
            vm.prank(participant);
            earlyBirds.register{value: 0.01 ether}();
        }

        // Attempt to register the 2001st participant
        address participant2001 = address(0x2001);
        vm.deal(participant2001, 0.1 ether); 
        vm.prank(participant2001);
        vm.expectRevert("Max participants reached");
        earlyBirds.register{value: 0.01 ether}();
    }

    function testWithdrawBNB() public {
        // Start the activity and register a participant
        vm.prank(owner);
        earlyBirds.startActivity();
        
        // Fund participant1 with enough BNB for registration
        vm.deal(participant1, 0.1 ether); 
        vm.prank(participant1);
        earlyBirds.register{value: 0.01 ether}();

        // Check the balance of the EarlyBirds contract
        uint256 earlyBirdsBalance = address(earlyBirds).balance;
        console.log("EarlyBirds balance before withdrawal:", earlyBirdsBalance);
        
        // Check the initial balance of the owner
        uint256 initialBalance = address(participant1).balance;
        console.log("Initial balance of owner:", initialBalance);
        
        // Withdraw BNB
        vm.prank(owner); // Ensure the call is made by the owner
        // earlyBirds.withdraw(address(0)); // Withdraw BNB
        earlyBirds.withdraw(address(participant1), address(0), earlyBirdsBalance);

        // Check the owner's balance after withdrawal
        assertGt(address(participant1).balance, initialBalance, "Owner should have more BNB after withdrawal");
    }

    function testWithdrawERC20() public {
        // This test assumes you have an ERC20 token contract deployed
        // You would need to deploy a mock ERC20 token and transfer it to the EarlyBirds contract
        // For simplicity, this part is omitted in this example
    }
} 