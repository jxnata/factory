// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Base.sol";

contract CollectionFactory is Ownable {
    // keep track of created Base addresses in array
    address[] public collections;
    // implementation is the address of the Base contract to clone
    address public implementation;

    // function to owner change the Base contract
    function setImplementation(address contractAddress)
        public
        onlyOwner
        returns (address)
    {
        implementation = contractAddress;
        return implementation;
    }

    // function to create a new contract, using clone()
    function createCollection(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) external returns (address) {
        address clone = Clones.clone(implementation);
        Base(clone).initialize(_name, _symbol, _uri, msg.sender);
        collections.push(clone);

        return clone;
    }
}
