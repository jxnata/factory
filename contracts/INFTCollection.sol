// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface INFTCollection {
    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _image,
        string memory _uri,
        uint _maxSupply,
        address _minter,
        address ownerAddress
    ) external;

    function gatedMint(address to, uint quantity) external;
}
