pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";

contract NFTTest is Test {
    uint64 num = 1;
    NFT testNft;

    function setUp() external {
        console.log("[Set Up--");
        testNft = new NFT();
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
        assertEq(testNft.owner(), address(this)); // this is the expected msg.sender within tests
    }

    function testGetBtcPriceFromChainlink() public {
        console.log("[testGetBtcPrice]");
        int256 price = testNft.getBtcPrice();
        string memory priceStr = vm.toString(price);
        console.log("Current BTC Price (Raw):%s", priceStr);
        string memory scaledStr = vm.toString(uint256(price) / 1e8);
        console.log("Current BTC Price (Scaled):%s", scaledStr);
        assertGt(price, 0, "BTC price should be > 0");
        console.log("Did we get here?");
    }
}
