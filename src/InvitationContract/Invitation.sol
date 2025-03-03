// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import third-party contract interface
interface ITeam {
    function team(address _addr) external view returns (address);
}

contract Invitation is Ownable {
    ITeam public teamContract; // Instance of the third-party contract
    bool public isTeamCheckEnabled; // Flag to enable or disable team contract check

    // Contract state variables
    uint256 public totalInviters; // Total number of inviters
    uint256 public totalInvitees; // Total number of invitees

    // Invitation information structure
    struct InviteInfo {
        address[] inviterList; // List of inviters
        uint256 count; // Number of invitations
    }

    mapping(address => InviteInfo) public inviteInfo; // Invitee -> Invitation information
    mapping(address => address) public inviter; // Invitee -> Inviter
    mapping(address => bool) public isInvited; // Whether the invitee has set an inviter

    event Invited(address indexed inviter, address indexed invitee);
    
    // Constructor
    constructor(address _owner) Ownable(_owner) {
        isTeamCheckEnabled = false; // Default to not enabling team contract check
    }

    // Admin sets the team contract address
    function setTeamContract(address _teamContract) external onlyOwner {
        teamContract = ITeam(_teamContract); // Set the team contract address without restrictions
    }

    // Admin controls whether to enable team contract check
    function setTeamCheckEnabled(bool _enabled) external onlyOwner {
        isTeamCheckEnabled = _enabled; // Set whether to enable team contract check
    }

    // Query the current inviter of a user
    function getCurrentInviter(address _user) external view returns (address) {
        // Query the inviter in the current contract
        address currentInviter = inviter[_user];
        
        // If team contract check is enabled, query the inviter in the team contract
        if (isTeamCheckEnabled) {
            address teamInviter = teamContract.team(_user);
            // If there is an inviter in the team contract, return the team contract inviter
            if (teamInviter != address(0)) {
                return teamInviter;
            }
        }
        
        // Return the inviter in the current contract
        return currentInviter;
    }

    // Bind invitation relationship
    function bindInvitation(address _inviter) external {
        require(_inviter != address(0), "Inviter cannot be zero address"); // Ensure the inviter address is not zero
        require(!isContract(_inviter), "Inviter cannot be contract address"); // Ensure the inviter is not a contract address
        require(inviter[msg.sender] == address(0), "Invitee already has an inviter"); // Ensure the invitee has not set an inviter yet
        require(_inviter != msg.sender, "Inviter and invitee cannot be the same"); // Ensure the inviter and invitee are not the same person

        // New check to prevent mutual invitations
        require(inviter[_inviter] != msg.sender, "Mutual invitations are not allowed"); // Ensure the inviter is not already invited by the invitee

        // Check if team contract check is enabled
        if (isTeamCheckEnabled) {
            // Check if msg.sender has already been added in the team contract
            address existingInviter = teamContract.team(msg.sender);
            require(existingInviter == address(0), "Already invited in team contract"); // Ensure not already invited in the team contract
        }

        inviter[msg.sender] = _inviter; // Set the inviter for the invitee
        isInvited[msg.sender] = true; // Mark the invitee as having set an inviter

        // Update invitation information
        inviteInfo[_inviter].inviterList.push(msg.sender); // Add the invitee to the inviter's list
        inviteInfo[_inviter].count++; // Increase the number of invitations

        // Update total inviters and invitees count
        if (inviteInfo[_inviter].count == 1) {
            totalInviters++; // If this is the first invitation for this inviter, increase total inviters count
        }
        totalInvitees++; // Increase total invitees count

        emit Invited(_inviter, msg.sender); // Emit the invitation event
    }

    // Admin manually sets the inviter
    function setInviter(address _invitee, address[] calldata _inviterList) external onlyOwner {
        require(_invitee != address(0), "Invitee cannot be zero address"); // Ensure the invitee is not zero address
        require(_inviterList.length > 0, "Inviter list cannot be empty"); // Ensure the inviter list is not empty
        require(!isContract(_invitee), "Invitee cannot be contract address"); // Ensure the invitee is not a contract address
        require(inviter[_invitee] == address(0), "Invitee already has an inviter"); // Ensure the invitee has not set an inviter yet

        for (uint256 i = 0; i < _inviterList.length; i++) {
            address _inviter = _inviterList[i];
            // Check the validity of the inviter address
            if (_inviter != address(0) && !isContract(_inviter) && _inviter != _invitee) {
                // Check if team contract check is enabled
                if (isTeamCheckEnabled) {
                    // Check if the inviter has already been added in the team contract
                    address existingInviter = teamContract.team(_inviter);
                    if (existingInviter != address(0)) {
                        continue; // If already invited in the team contract, skip this iteration
                    }
                }

                inviter[_invitee] = _inviter; // Set the inviter for the invitee
                isInvited[_invitee] = true; // Mark the invitee as having set an inviter

                // Update invitation information
                inviteInfo[_inviter].inviterList.push(_invitee); // Add the invitee to the inviter's list
                inviteInfo[_inviter].count++; // Increase the number of invitations

                // Update total inviters and invitees count
                if (inviteInfo[_inviter].count == 1) {
                    totalInviters++; // If this is the first invitation for this inviter, increase total inviters count
                }
                totalInvitees++; // Increase total invitees count

                emit Invited(_inviter, _invitee); // Emit the invitation event
            }
        }
    }

    // Get the total number of inviters and invitees in the contract
    function getTotalCounts() external view returns (uint256, uint256) {
        return (totalInviters, totalInvitees); // Return total inviters and invitees count
    }
    // Get the invitation information for a specific address
    function getInviteInfo(address _invitee) external view returns (address[] memory) {
        // Return the inviter list for the specified invitee
        return inviteInfo[_invitee].inviterList; // Return the detailed list of inviters
    }

    // Check if an address is a contract address
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0; // Return true if the address is a contract
    }

    // Withdraw assets from the contract
    function withdraw(address _token) external onlyOwner {
        if (_token == address(0)) {
            // Withdraw BNB
            payable(owner()).transfer(address(this).balance);
        } else {
            // Withdraw ERC20 assets
            IERC20 token = IERC20(_token);
            uint256 balance = token.balanceOf(address(this));
            require(balance > 0, "No tokens to withdraw"); // Ensure there are tokens to withdraw
            token.transfer(owner(), balance); // Transfer tokens to the owner
        }
    }

    // Receive ETH
    receive() external payable {}

    
}
