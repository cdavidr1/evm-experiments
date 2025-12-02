// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";
import {ChainConfig} from "./ChainConfig.s.sol";

contract Deploy is Script {
    function run() external returns (NFT) {
        // Before startBroadcast - simulated
        ChainConfig chain = new ChainConfig();
        address BTCUSD_FEED = chain.activeConfig();

        vm.startBroadcast();
        NFT deployed = new NFT(BTCUSD_FEED);
        vm.stopBroadcast();
        return deployed;
    }
}
