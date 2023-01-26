// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

contract NFTCollection is
    ERC721Upgradeable,
    PausableUpgradeable,
    OwnableUpgradeable,
    ERC721BurnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using StringsUpgradeable for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;

    string public image;
    string private baseUri;
    address public minter;
    uint private MAX_SUPPLY;

    constructor() ERC721Upgradeable() {}

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _image,
        string memory _uri,
        uint _maxSupply,
        address _minter,
        address _owner
    ) external initializer nonReentrant {
        __ERC721_init(_name, _symbol);
        __Ownable_init();
        transferOwnership(_owner);
        image = _image;
        baseUri = _uri;
        minter = _minter;
        MAX_SUPPLY = _maxSupply;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function totalSupply() public view returns (uint) {
        return MAX_SUPPLY;
    }

    function circulationSupply() public view returns (uint) {
        uint256 current = _tokenIdCounter.current();
        return current;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory base = baseUri;
        return
            bytes(base).length > 0
                ? string(abi.encodePacked(base, tokenId.toString()))
                : "";
    }

    /**
     * @dev Public function to mint a new token.
     * Executed if msg.sender is a valid minter
     *
     * @param to target address that will receive the tokens
     * @param quantity quantity of tokens to mint
     */
    function gatedMint(
        address to,
        uint quantity
    ) public canMint onlyMintManager returns (uint minted) {
        uint256 tokenId = _tokenIdCounter.current();
        require(MAX_SUPPLY == 0 || MAX_SUPPLY > tokenId, "Sold out!");

        for (uint i = 0; i < quantity; i++) {
            _tokenIdCounter.increment();
            _safeMint(to, tokenId + i);
        }
        return quantity;
    }

    /**
     * @dev Mint new tokens, only collection owner can mint.
     *
     * @param to target address that will receive the tokens
     */
    function safeMint(address to) public onlyOwner canMint {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Modifier to verify if mint is possible, based on max_supply.
     */
    modifier canMint() {
        uint256 tokenId = _tokenIdCounter.current();
        require(MAX_SUPPLY == 0 || MAX_SUPPLY > tokenId, "Sold out!");
        _;
    }

    /**
     * @dev Modifier to verify if msg.sender is a valid minter.
     */
    modifier onlyMintManager() {
        require(
            msg.sender == minter && minter != address(0x0),
            "Only Mint Manager address can mint new tokens."
        );
        _;
    }
}
