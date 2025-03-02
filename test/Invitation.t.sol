// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Invitation} from "../src/InvitationContract/Invitation.sol";

contract MockTeamContract {
    mapping(address => address) public _team; // Changed to _team

    function addTeamMember(address _member, address _inviter) external {
        _team[_member] = _inviter;
    }

    function team(address _addr) external view returns (address) {
        return _team[_addr];
    }
}

contract InvitationTest is Test {
    Invitation invitation;
    MockTeamContract teamContract;

    address owner;
    address addr1;
    address addr2;

    function setUp() public {
        // Deploy a mock team contract
        teamContract = new MockTeamContract();

        // Deploy the InvitationContract with the deployer as the owner
        owner = address(this); // The deployer is the test contract itself
        invitation = new Invitation(owner); // Pass the owner address

        // Set the team contract address
        invitation.setTeamContract(address(teamContract));

        // Get addresses
        addr1 = address(0x1);
        addr2 = address(0x2);
    }

    function testBindInvitation() public {
        vm.prank(owner);
        invitation.bindInvitation(addr1);
        address currentInviter = invitation.getCurrentInviter(owner);
        assertEq(currentInviter, addr1);
    }

    function testCannotBindMultipleInviters() public {
        vm.prank(owner);
        invitation.bindInvitation(addr1);
        vm.expectRevert("Invitee already has an inviter");
        invitation.bindInvitation(addr1);
    }

    function testAdminSetInviter() public {
        address[] memory inviterList = new address[](1);
        inviterList[0] = addr1;

        vm.prank(owner);
        invitation.setInviter(addr2, inviterList);
        address currentInviter = invitation.getCurrentInviter(addr2);
        assertEq(currentInviter, addr1);
    }

    function testQueryCurrentInviter() public {
        vm.prank(owner);
        invitation.bindInvitation(addr1);
        address currentInviter = invitation.getCurrentInviter(owner);
        assertEq(currentInviter, addr1);
    }

    function testSetTeamContract() public {
        vm.prank(owner);
        invitation.setTeamContract(address(teamContract));
        assertEq(address(invitation.teamContract()), address(teamContract)); // Ensure both are addresses
    }

    function testEnableTeamCheck() public {
        vm.prank(owner);
        invitation.setTeamCheckEnabled(true);
        assertTrue(invitation.isTeamCheckEnabled());
    }

    function testMutualInvitationNotAllowed() public {
        // A invites B
        vm.prank(addr1);
        invitation.bindInvitation(addr2); // addr1 (A) invites addr2 (B)

        // Now B tries to invite A
        vm.prank(addr2); // Switch to addr1's context
        vm.expectRevert("Mutual invitations are not allowed"); // Expect revert due to existing inviter
        invitation.bindInvitation(addr1); // addr2 (B) tries to invite addr1 (A)
    }
}