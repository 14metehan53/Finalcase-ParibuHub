// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Sword is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Sword", "SWR") {}

    struct Swords {
        uint ID;
        uint8 power;
        uint8 plus;
    }

    mapping(uint => Swords) public idToSwords;

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();

        uint8 additionalPower = randNum(15);
        Swords memory sword;

        sword.ID = tokenId;
        sword.power = additionalPower;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function setSwordMap(uint _id, uint8 _power, uint8 _plus) public {
        idToSwords[_id].power = _power;
        idToSwords[_id].plus = _plus;
    }

    function viewSword(uint _id) public view returns(Swords memory) {
        return idToSwords[_id];
    }

    function randNum(uint8 range) private view returns(uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))) % range;
    }


}
