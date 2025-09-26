pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "forge-std/console.sol";

import {ERC721A} from "ERC721A/ERC721A.sol";
import {MerkleProofLib} from "solady/utils/MerkleProofLib.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {ReentrancyGuardTransient} from "solady/utils/ReentrancyGuardTransient.sol";

contract NftBasic is Ownable, ReentrancyGuardTransient, ERC721A {
}
