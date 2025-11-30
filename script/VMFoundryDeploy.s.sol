// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        new NFT();
        vm.stopBroadcast();
    }
}
