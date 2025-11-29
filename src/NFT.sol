//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC721A} from "ERC721A/ERC721A.sol";
import {MerkleProofLib} from "solady/utils/MerkleProofLib.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {ReentrancyGuardTransient} from "solady/utils/ReentrancyGuardTransient.sol";

contract NFT is Ownable, ReentrancyGuardTransient, ERC721A {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          ERRORS                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The user already minted for phase.
    error AlreadyMinted();

    /// @dev The `msg.value` is incorrect.
    error IncorrectPrice();

    /// @dev The public sale is started.
    error PublicSaleStarted();

    /// @dev The phase not started yet.
    error NotStarted();

    /// @dev The total supply reached MAX_SUPPLY.
    error MaxSupplyReached();

    /// @dev The token does not exist.
    error TokenDoesNotExist();

    /// @dev The mint quantity is invalid.
    error InvalidQuantity();

    /// @dev The Merkle proof is not valid.
    error IncorrectProof();

    /// @dev The action is currently not allowed.
    error NotAllowed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Mint price for a mint.
    uint64 public mintPrice;

    /// @dev The merkle root for og whiltelist.
    bytes32 public ogMerkleRoot;

    /// @dev The merkle root for white whitelist.
    bytes32 public whiteMerkleRoot;

    /// @notice The sale phase enum.
    /// 0 - Closed, 1 - Og Phase 1, 2 - White Phase 2, 3 - Public Sale
    enum SalePhase {
        Closed,
        OgList,
        WhiteList,
        Public
    }
    SalePhase public salePhase;

    /// @dev Maximum supply of tokens.
    uint64 public constant MAX_SUPPLY = 1234;

    /// @dev Maximum number of tokens mintable.
    uint64 public constant MAX_MINT = 5;

    /// @dev The baseURI for a token.
    string internal baseURI;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CONSTRUCTOR                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    constructor() ERC721A(name(), symbol()) {
        ogMerkleRoot = 0x8cfced217f43531ef98b85c09752bf88fb067f751fddcc62c334df07d7dc5559;
        whiteMerkleRoot = 0xbba0b526b0ada9d54799475bd1ff24765bfcf57c30bd14bebe90274bbcb95bbf;
        mintPrice = 0.05 ether;
        salePhase = SalePhase.Closed;
        _initializeOwner(msg.sender);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           ADMIN                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @notice Update the whitelists.
    function setRoots(
        bytes32 _merkleRootA,
        bytes32 _merkleRootB
    ) external onlyOwner {
        ogMerkleRoot = _merkleRootA;
        whiteMerkleRoot = _merkleRootB;
    }

    /// @notice Update the mint price.
    function setPrice(uint64 _price) external onlyOwner {
        mintPrice = _price;
    }

    /// @notice Update the baseURI for a token.
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    /// @notice Set the active sale phase.
    function setSalePhase(SalePhase _phase) external onlyOwner {
        salePhase = _phase;
    }

    /// @notice Withdraws all available ethers to the owner.
    function withdrawPay() external onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          PUBLIC                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @notice The name of the token.
    function name() public pure override returns (string memory) {
        return "Pepega";
    }

    /// @notice The symbol of the token.
    function symbol() public pure override returns (string memory) {
        return "P";
    }

    /// @notice The URI for a token.
    function tokenURI(uint256 id) public view override returns (string memory) {
        /// Revert if token `id` does not exist.
        if (_exists(id) == false) {
            revert TokenDoesNotExist();
        }
        return LibString.concat(baseURI, LibString.toString(id));
    }

    /// @notice og mint to `msg.sender`.
    function ogMint(
        uint256 quantity,
        bytes32[] calldata _proof
    ) external payable nonReentrant {
        // Ensure quantity is within allowed limit
        if (quantity == 0 || quantity > MAX_MINT) revert InvalidQuantity();

        unchecked {
            // If not og phase sale then revert
            if (salePhase == SalePhase.OgList) {
                // Retrieve how many have already been minted by this address
                uint64 mintedCount = _getAux(msg.sender);

                // Make sure not to exceed 5 tokens total per address
                if (mintedCount + quantity > MAX_MINT) revert AlreadyMinted();

                if (totalSupply() + quantity > MAX_SUPPLY)
                    revert MaxSupplyReached();

                // Verify payment
                if (msg.value != (mintPrice * quantity))
                    revert IncorrectPrice();

                // Revert if given proof is not valid.
                if (
                    !MerkleProofLib.verify(
                        _proof,
                        ogMerkleRoot,
                        keccak256(abi.encodePacked(msg.sender))
                    )
                ) {
                    revert IncorrectProof();
                }

                // Update the mint count for this address
                _setAux(msg.sender, mintedCount + uint64(quantity));

                // Mint `quantity` Pepega
                _safeMint(msg.sender, quantity);
                return;
            }
            revert NotAllowed();
        }
    }

    /// @notice white mint to `msg.sender`.
    function whiteMint(
        uint256 quantity,
        bytes32[] calldata _proof
    ) external payable nonReentrant {
        // Ensure quantity is within allowed limit
        if (quantity == 0 || quantity > MAX_MINT) revert InvalidQuantity();

        unchecked {
            // If not white sale then revert
            if (salePhase == SalePhase.WhiteList) {
                // Retrieve how many have already been minted by this address
                uint64 mintedCount = _getAux(msg.sender);

                // Make sure not to exceed 5 tokens total per address
                if (mintedCount + quantity > MAX_MINT) revert AlreadyMinted();

                if (totalSupply() + quantity > MAX_SUPPLY)
                    revert MaxSupplyReached();

                // Verify payment
                if (msg.value != (mintPrice * quantity))
                    revert IncorrectPrice();

                // Revert if given proof is not valid.
                if (
                    !MerkleProofLib.verify(
                        _proof,
                        whiteMerkleRoot,
                        keccak256(abi.encodePacked(msg.sender))
                    )
                ) {
                    revert IncorrectProof();
                }

                // Update the mint count for this address
                _setAux(msg.sender, mintedCount + uint64(quantity));

                // Mint `quantity` Pepega
                _safeMint(msg.sender, quantity);
                return;
            }
            revert NotAllowed();
        }
    }

    /// @notice Public mint to `msg.sender`.
    /// Requirements:
    /// - The public sale has started.
    /// - The `msg.value` is correct.
    /// - Only allows up to 5 mint per address.
    function publicMint(uint256 quantity) external payable nonReentrant {
        // Ensure quantity is within allowed limit
        if (quantity == 0 || quantity > MAX_MINT) revert InvalidQuantity();
        if (salePhase != SalePhase.Public) revert NotStarted();
        unchecked {
            // Check supply
            if (totalSupply() + quantity > MAX_SUPPLY)
                revert MaxSupplyReached();

            // Retrieve how many have already been minted by this address
            uint64 mintedCount = _getAux(msg.sender);

            // Make sure not to exceed 5 tokens total per address
            if (mintedCount + quantity > MAX_MINT) revert AlreadyMinted();

            // Verify payment
            if (msg.value != (mintPrice * quantity)) revert IncorrectPrice();

            // Update the mint count for this address
            _setAux(msg.sender, mintedCount + uint64(quantity));

            // Mint `quantity` Pepega
            _safeMint(msg.sender, quantity);
        }
    }
}
