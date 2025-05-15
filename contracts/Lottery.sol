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

    event LotteryEntered(address indexed player, uint guess);
    event WinningNumberDrawn(uint number);
    event LotteryReset();
    event FundsWithdrawn(address indexed to, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function enterLottery(uint[] memory guesses) public payable {
        require(isLotteryOpen, "Lottery closed");
        require(!hasEntered[msg.sender], "Already entered");
        require(msg.value == entryFee, "Incorrect entry fee");
        require(guesses.length == 6, "Must be 6 numbers");

        // Encode guesses into a single number or store the array as-is if needed
        uint guessHash = uint(keccak256(abi.encodePacked(guesses)));

        entries.push(Entry(msg.sender, guessHash));
        hasEntered[msg.sender] = true;

        emit LotteryEntered(msg.sender, guessHash);
    }

    function drawWinningNumber(uint _number) public onlyOwner {
        require(isLotteryOpen, "Already drawn");
        require(_number >= 100000 && _number <= 999999, "Must be 6 digits");

        winningNumber = _number;
        isLotteryOpen = false;
        isWinnerDrawn = true;

        emit WinningNumberDrawn(_number);
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

    function resetLottery() public onlyOwner {
        // Reset participation mapping before deleting entries
        for (uint i = 0; i < entries.length; i++) {
            hasEntered[entries[i].player] = false;
        }

        delete entries;
        isLotteryOpen = true;
        isWinnerDrawn = false;
        winningNumber = 0;

        emit LotteryReset();
    }

    function withdrawFunds() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "Nothing to withdraw");
        payable(owner).transfer(balance);

        emit FundsWithdrawn(owner, balance);
    }

    function totalPlayers() public view returns (uint) {
        return entries.length;
    }
}
