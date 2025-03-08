// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script, console} from "forge-std/Script.sol";
import {EarlyBirds} from "../src/EarlyBirdsContract/EarlyBirds.sol";

contract EarlyBirdsScript is Script {
    EarlyBirds public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new EarlyBirds(msg.sender,0x0000000000000000000000000000000000000000);

        vm.stopBroadcast();
    }
}
