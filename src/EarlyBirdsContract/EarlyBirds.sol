// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

contract EarlyBirds is Ownable {
    uint256 public constant REGISTRATION_FEE = 0.01 ether; // 0.01 BNB
    uint256 public constant MAX_PARTICIPANTS = 2000;

    mapping(address => bool) public participants; // Record of participants
    address[] public participantList; // List of participant addresses
    bool public isActive; // Activity status

    event Registered(address indexed participant);
    event ActivityStarted();
    event ActivityPaused();
    event Withdrawn(address indexed to,address indexed token, uint256 amount);

    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Contracts are not allowed");
        _;
    }

    modifier whenActive() {
        require(isActive, "Activity is not active");
        _;
    }

    constructor(address _owner) Ownable(_owner) {
        isActive = false; // Initial state is inactive
    }

    // Registration function
    function register() external payable onlyEOA whenActive {
        require(msg.value == REGISTRATION_FEE, "Incorrect registration fee");
        require(!participants[msg.sender], "Already registered");
        require(participantList.length < MAX_PARTICIPANTS, "Max participants reached");
        participants[msg.sender] = true;
        participantList.push(msg.sender);

        emit Registered(msg.sender);
    }

    // Query if a specific address has participated in the early bird purchase
    function isRegistered(address _address) external view returns (bool) {
        return participants[_address];
    }

    // Get the list of participants
    function getParticipantList() external view returns (address[] memory) {
        return participantList;
    }

    // Admin starts the activity
    function startActivity() external onlyOwner {
        isActive = true;
        emit ActivityStarted();
    }

    // Admin pauses the activity
    function pauseActivity() external onlyOwner {
        isActive = false;
        emit ActivityPaused();
    }

    // Withdraw assets from the contract
    function withdraw(
        address _to,
        address _token,
        uint256 _value
    ) public onlyOwner {
        if (_token == address(0)) {
            (bool success, ) = _to.call{value: _value}(new bytes(0));
            require(success, "!safeTransferETH");
        } else {
            // bytes4(keccak256(bytes('transfer(address,uint256)')));
            (bool success, bytes memory data) = _token.call(
                abi.encodeWithSelector(0xa9059cbb, _to, _value)
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "!safeTransfer"
            );
        }
    }
     // Receive BNB
    receive() external payable {}
}