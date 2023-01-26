// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./INFTCollection.sol";

struct INO {
    bool enabled;
    uint price;
    uint start;
    uint end;
    uint maxMint;
    uint maxWallet;
}

contract MintManager is Ownable {
    mapping(address => INO) mintList;

    /**
     * @dev Public function to mint a new token.
     * Executed if the collection is allowed to mint.
     *
     * @param collection target contract address to mint tokens.
     * @param to address that will receive the tokens.
     * @param quantity quantity of tokens to mint.
     */
    function mint(
        address collection,
        address to,
        uint quantity
    ) external payable {
        INO memory ino = mintList[collection];
        require(ino.enabled, "Mint is not allowed.");
        require(ino.start <= block.timestamp, "Mint not started.");
        require(ino.end > block.timestamp || ino.end == 0, "Mint ended.");
        require(msg.value >= ino.price, "The amount is less than the price.");
        require(
            quantity <= ino.maxMint,
            "Maximum number of tokens per mint reached."
        );
        uint balance = ERC721(collection).balanceOf(to);
        require(
            balance < ino.maxWallet,
            "Maximum number of tokens per wallet reached."
        );

        INFTCollection(collection).gatedMint(to, quantity);
    }

    /**
     * @dev Public function to manage the Initial Token Offer.
     *
     * @param collection target contract address to mint tokens.
     * @param price price for each mint.
     * @param start start date (0 to have no start date).
     * @param end end date (0 to have no end date).
     * @param maxMint max number of tokens per mint.
     * @param maxWallet max number of tokens per wallet.
     */
    function manageINO(
        address collection,
        uint price,
        uint start,
        uint end,
        uint maxMint,
        uint maxWallet
    ) public {
        address owner = Ownable(collection).owner();
        require(owner == msg.sender, "Only owner can manage the ITO.");

        INO memory newINO = INO(true, price, start, end, maxMint, maxWallet);
        mintList[collection] = newINO;
    }

    /**
     * @dev Public function to get details of Initial Token Offer.
     *
     * @param collection target contract address
     */
    function getINO(address collection) public view returns (INO memory) {
        return mintList[collection];
    }
}
