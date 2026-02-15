//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Election {

    string[] public electors;
    uint256 public maxVotes;
    uint256 public electionEndTime;
    address public contractOwner;

    mapping(address => bool) public userVotes;
    mapping(uint256 => uint256) public votesCount;

    error YourAddressCantVote();
    error ElectorDoesNotExist(uint256 _pickedElector, uint256 _totalElectors);
    error OnlyForOwner();

    event Voted(uint256 _index, address _userAddress);
    event MaxVoteReseted();

    modifier OnlyOwner() { //Perform before function
        require(msg.sender == contractOwner, OnlyForOwner());
        _;
    }

    //["Alex","Kostya","Micke"]

    constructor(string[] memory _electors, uint256 _maxVotes, uint256 _electionTime) {
        electors = _electors;
        maxVotes = _maxVotes;
        electionEndTime = block.timestamp + _electionTime;
        contractOwner = msg.sender;
    }

    function vote(uint256 _numberOfElector) public {
        require(userVotes[msg.sender] == false, YourAddressCantVote());
        require(_numberOfElector < electors.length, ElectorDoesNotExist(_numberOfElector, electors.length));
        require(votesCount[_numberOfElector] <= maxVotes - 1, "Max Votes");
        require(msg.sender != contractOwner, "Contract owner can't vote");
        require(block.timestamp < electionEndTime, "Voting is over");

        userVotes[msg.sender] = true;
        votesCount[_numberOfElector] += 1;

        emit Voted(_numberOfElector, msg.sender);
    }

    function resetMaxVotes(uint256 _newMaxVotes) public OnlyOwner {
        require(_newMaxVotes > maxVotes, "Max votes can't decrease");
        maxVotes = _newMaxVotes;
        emit MaxVoteReseted();
    }

    function resetElectionTime(uint256 _newElectionTime) public {
        require(msg.sender == contractOwner, OnlyForOwner());
        require(_newElectionTime > electionEndTime, "Election time can't decrease");
        electionEndTime = _newElectionTime;
    }
    function electionResult() public view returns(string memory winner) {
        uint256 leaderIndex = 0;
        for (uint256 i = 0; i < electors.length; i++) {
            if (votesCount[i] > votesCount[leaderIndex]) {
                leaderIndex = i;
            }
        }
        return electors[leaderIndex];
    }

}

contract MathModifier {
    uint256 public value = 1;
    uint256 public x = 10;

    modifier sandwich() {
        value += 1;
        _;
        value +=2;
    }

    function exampleFunc() public sandwich {
        value *=2;
    }

    modifier checker(uint256 _numberToCheck) {
        require(_numberToCheck >= 10, "Number less than 10");
        _;
    }

    function summNumbers(uint256 _x) public checker(_x) {
        x = _x * 100;
    }

}

contract Store is Ownable {
    struct Product {
        string name;
        uint256 stock;
        uint256 id;
        uint256 price;
    }
    Product[] public products;

    error IdAlreadyExist();
    error IdDoesNotExist();

    constructor() Ownable(msg.sender) {}

    function addProduct(string calldata _name, uint256 _stock, uint256 _id, uint256 _price) external onlyOwner {
        require(isIdExist(_id) == false, IdAlreadyExist());
        products.push(Product(_name, _stock, _id, _price));
    }

    function deleteProduct(uint256 _id) external onlyOwner {
        (bool status, uint256 index) = findIndexById(_id);
        require(status,IdDoesNotExist());

        products[index] = products[products.length - 1];
        products.pop();

    }

    function getTimestamp() public view onlyOwner returns(uint256) {
        return block.timestamp;
    }

    function updatePrice(uint256 _id, uint256 _price) external onlyOwner {
        Product storage thisProduct = findProduct(_id); //don't rewrite
        thisProduct.price = _price;
    }

    function updateStock(uint256 _id, uint256 _stock) external onlyOwner {
        Product storage thisProduct = findProduct(_id);
        thisProduct.stock = _stock;
    }

    function getPrice(uint256 _id) public view returns(uint256) {
        Product storage thisProduct = findProduct(_id);
        return thisProduct.price;
    }

    function getStock(uint256 _id) public view returns(uint256) {
        Product storage thisProduct = findProduct(_id);
        return thisProduct.stock;
    }

    function findProduct(uint256 _id) internal view returns(Product storage product) {
        for(uint256 i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                return products[i];
            }
        }
        revert  ("Product not found");
    }

    function isIdExist(uint256 _id) internal view returns(bool) {
        for(uint256 i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                return true;
            }
        }
        return false;
    }

    function findIndexById(uint256 _id) internal view returns(bool, uint256) {
        for(uint256 i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                return (true, i);
            }
        }
        return (false, 0);
    }
}

contract Links {
    uint256[] public data = [0, 10, 555];

    function modifyData() public {
        uint256[] storage storageRef = data; //link of data, cheaper
        storageRef[0] = 44;
    }

    function notModifyDatd() public view {
        uint256[] memory storageRef = data; //new data in memory
        storageRef[0] = 44;
    }
}