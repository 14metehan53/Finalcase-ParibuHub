// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RewardToken.sol";
import "./zPotion.sol";
import "./swords.sol";

contract MmoDarkness {

    Gold public gold;
    ZPot public zpot;
    Sword public sword;

    struct Warrior {
        uint health;
        uint maxHealth;
        uint attackPower;
        uint gold;
        bool isRegistered;
        uint runTime;
        uint swordID;
    }

    struct Mob {
        uint health;
        uint maxHealth;
        uint attackPower;
        uint reward;
    }

    struct Item {
        string name;
        uint ID;
        uint price;
        uint power;
    }

    constructor(address _goldAddress, address _zPotAddress, address _swordAddress) {
        gold = Gold(_goldAddress);
        zpot = ZPot(_zPotAddress);
        sword = Sword(_swordAddress);

        addItem("small potion", 0, 40, 30);
        addItem("medium potion", 1, 75, 60);
        addItem("big potion", 2, 130, 100);

        addMonster(100,10,25);
        addMonster(180,35,80);
        addMonster(260,60,160);
    }

    mapping(address => Warrior) public warriors;
    mapping(uint => Item) public idToItems;

    Mob[] public mobs;

    function start() public {
        Warrior memory warrior;
        warrior.isRegistered = true;
        require(warrior.isRegistered == true);

        warrior.health = 100;
        warrior.maxHealth = 100;
        warrior.attackPower = 15;
        warriors[msg.sender] = warrior;
    }

    function attack(uint _id) public wait {
        uint8 swordPower = sword.viewSword(warriors[msg.sender].swordID).power;

        if (warriors[msg.sender].attackPower + swordPower >= mobs[_id].health) {
            uint8 posibility = randNum(15);

            warriors[msg.sender].health -= mobs[_id].attackPower;
            gold.mint(msg.sender, mobs[_id].reward);
            warriors[msg.sender].gold += mobs[_id].reward;
            mobs[_id].health = mobs[_id].maxHealth;

            if (posibility <= 5) {
                sword.safeMint(msg.sender);
            }

        } else {

            warriors[msg.sender].health -= mobs[_id].attackPower;
            mobs[_id].health -= (warriors[msg.sender].attackPower + swordPower);
            
        }
    }

    function equipSword(uint _id) public {
        require(sword.ownerOf(_id) == msg.sender);
        warriors[msg.sender].swordID = _id;
    }

    function useZPotion(uint _id) public wait {
        zpot.burn(msg.sender, _id, 1);

        if ((warriors[msg.sender].health + idToItems[_id].power) >= warriors[msg.sender].health) {
            warriors[msg.sender].health = warriors[msg.sender].maxHealth;
        } else {
            warriors[msg.sender].health += idToItems[_id].power;
        }
    }

    function buyZPot(uint _id, uint _amount) public wait {
        require(warriors[msg.sender].gold >= idToItems[_id].price * _amount);
        warriors[msg.sender].gold -= idToItems[_id].price * _amount;
        zpot.mint(msg.sender, _id, _amount,"");
    }

    function addItem(string memory _name, uint _id, uint _price, uint _power) private {
        Item memory item;

        item.name = _name;
        item.ID = _id;
        item.price = _price;
        item.power = _power;
        idToItems[_id] = item;
    }

    function run() public wait {

        if (warriors[msg.sender].runTime == 0) {
            warriors[msg.sender].runTime = block.timestamp;
        } else {
            warriors[msg.sender].runTime = 0;
            warriors[msg.sender].health = warriors[msg.sender].maxHealth;
        }
    }

    function upgradeSword(uint _id) public {

        require(sword.ownerOf(_id) == msg.sender);
        uint8 posibility = randNum(10);

        if (posibility >= sword.viewSword(_id).plus -1) {
            uint8 extraPower = randNum(10);
            sword.setSwordMap(_id, sword.viewSword(_id).power += extraPower, sword.viewSword(_id).plus +1);
        } else {
            warriors[msg.sender].swordID = 0;
            sword.burn(_id);
        }

    }

    function addMonster(uint _maxHealth, uint _attackPower, uint _reward) private {
        Mob memory mob;

        mob.health = _maxHealth;
        mob.maxHealth = _maxHealth;
        mob.attackPower = _attackPower;
        mob.reward = _reward;
        mobs.push(mob);
    }

    function randNum(uint8 range) private view returns(uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))) % range;
    }

    modifier wait() {
        require(block.timestamp >= warriors[msg.sender].runTime + 20 minutes);
        _;
    }

}