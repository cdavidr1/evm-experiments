pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {Deploy} from "../script/VMFoundryDeploy.s.sol";
contract NFTTest is Test {
    uint64 num = 1;
    NFT testNft;

    function setUp() external {
        Deploy deployer = new Deploy();
        console.log("[Set Up--");
        testNft = deployer.run();
        console.log("--End Set Up]");
    }

    function testCheck() public {
        console.log("[testCheck]");
        assertEq(num, 1);
    }

    function testMaxMintIsFive() public {
        console.log("[testMaxMintIsFive]");
        assertEq(testNft.MAX_MINT(), 5);
    }

    function testOwnerMsgSender() public {
        assertEq(testNft.owner(), address(msg.sender));
    }

    function testGetBtcPriceFromChainlink() public {
        console.log("[testGetBtcPrice]");
        int256 price = testNft.getBtcPrice();
        string memory priceStr = vm.toString(price);
        console.log("Current BTC Price (Raw):%s", priceStr);
        string memory scaledStr = vm.toString(uint256(price) / 1e8);
        console.log("Current BTC Price (Scaled):%s", scaledStr);
        assertGt(price, 0, "BTC price should be > 0");
    }
}
