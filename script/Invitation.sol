// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script, console} from "forge-std/Script.sol";
import {Invitation} from "../src/InvitationContract/Invitation.sol";

contract InvitationScript is Script {
    Invitation public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new Invitation(msg.sender);

        vm.stopBroadcast();
    }
}
