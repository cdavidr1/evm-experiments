pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";

contract ChainConfig {
    NetworkConfig public activeConfig;
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = getSepoliaConfig();
        } else if (block.chainid == 143) {
            activeConfig = getMonadConfig();
        } else {
            activeConfig = getLocalConfig();
        }
    }

    function getMonadConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory monadConfig = NetworkConfig({
            priceFeed: 0xc1d4C3331635184fA4C3c22fb92211B2Ac9E0546
        });
        return monadConfig;
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory monadConfig = NetworkConfig({
            priceFeed: 0xc1d4C3331635184fA4C3c22fb92211B2Ac9E0546
        });
        return monadConfig;
    }

    function getLocalConfig() public pure returns (NetworkConfig memory) {}
}
