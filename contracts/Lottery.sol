// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


contract Lottery {
    address public owner;
    uint public entryFee = 0.01 ether;
    bool public isLotteryOpen = true;
    uint public winningNumber;
    bool public isWinnerDrawn = false;

    struct Entry {
        address player;
        uint guess;
    }

    Entry[] public entries;
    mapping(address => bool) public hasEntered;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function enterLottery(uint guess) public payable {
        require(isLotteryOpen, "Lottery closed");
        require(!hasEntered[msg.sender], "Already entered");
        require(msg.value == entryFee, "Incorrect entry fee");
        require(guess >= 100000 && guess <= 999999, "Must be 6 digits");

        entries.push(Entry(msg.sender, guess));
        hasEntered[msg.sender] = true;
    }

    function drawWinningNumber(uint _number) public onlyOwner {
        require(isLotteryOpen, "Already drawn");
        require(_number >= 100000 && _number <= 999999, "Must be 6 digits");

        winningNumber = _number;
        isLotteryOpen = false;
        isWinnerDrawn = true;
    }

    function getWinners() public view returns (address[] memory) {
        require(isWinnerDrawn, "Not drawn yet");
        uint count = 0;
        for (uint i = 0; i < entries.length; i++) {
            if (entries[i].guess == winningNumber) {
                count++;
            }
        }

        address[] memory winners = new address[](count);
        uint j = 0;
        for (uint i = 0; i < entries.length; i++) {
            if (entries[i].guess == winningNumber) {
                winners[j] = entries[i].player;
                j++;
            }
        }
        return winners;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function totalPlayers() public view returns (uint) {
        return entries.length;
    }
}