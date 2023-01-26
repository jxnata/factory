// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./INFTCollection.sol";

contract CollectionFactory is Ownable {
    // baseContract is the address of the Base contract to clone
    address public baseContract;
    // mintManager is the address of the Mint Manager contract
    address public mintManager;

    /**
     * @dev Function to owner change the Base contract.
     */
    function changeBase(address _address) public onlyOwner {
        baseContract = _address;
    }

    /**
     * @dev Function to owner change the Mint Manager contract.
     */
    function changeManager(address _address) public onlyOwner {
        mintManager = _address;
    }

    /**
     * @dev Predict a contract address, based in _salt number.
     *
     * @param _salt Random 32 bytes number to generate the collection
     */
    function predict(bytes32 _salt) public view returns (address predicted) {
        address clone = Clones.predictDeterministicAddress(baseContract, _salt);
        return clone;
    }

    /**
     * @dev Create a new contract, using clone().
     *
     * @param _name Collection name
     * @param _image Collection image
     * @param _symbol Collection abbreviation
     * @param _uri Token base uri
     * @param _maxSupply Max number of tokens
     * @param _salt Random 32 bytes number to generate the collection
     */
    function create(
        string memory _name,
        string memory _image,
        string memory _symbol,
        string memory _uri,
        uint _maxSupply,
        bytes32 _salt
    ) external returns (address) {
        require(baseContract != address(0x0), "Invalid base contract!");

        address clone = Clones.cloneDeterministic(baseContract, _salt);
        INFTCollection(clone).initialize(
            _name,
            _symbol,
            _image,
            _uri,
            _maxSupply,
            mintManager,
            msg.sender
        );

        return clone;
    }
}
