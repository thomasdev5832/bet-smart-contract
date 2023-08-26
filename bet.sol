// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Bet {
    
    // Structs
    struct Player{
        uint256 amountBet;
        uint256 numberSelected;
    }

    // Properties
    address public owner;
    address[] public players;
    address[] public winners;
    uint256 public totalBet;
    uint256 public minimunBet;

    mapping(address => Player) addressToPlayer;

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

    // Constructor
    constructor (uint256 minimunBetValue) {
        owner = msg.sender;
        if(minimunBetValue != 0) {
            minimunBet = minimunBetValue;
        }else {
            revert("Invalid value");
        }
    }

    // Public Functions
    function bet(uint256 numberSelected) public payable {
        require(msg.value >= minimunBet * 10**18, "The bet amount is less than the minimum allowed");
        uint256 valueBet = msg.value;
        address playerBet = msg.sender;

        Player memory newPlayer = Player({
            numberSelected : numberSelected,
            amountBet: valueBet
        });
        addressToPlayer[playerBet] = newPlayer;

        totalBet += valueBet;
        players.push(playerBet);
    }

    function generateWinner() public isOwner{
        generateWinnerNumber();
    }

    // Private Functions
    function rewardWinner(uint256 numberPrizeGenerated)  private{
        uint256 count = 0;

        for(uint256 i = 0; i < players.length; i++){
            address playerAddress = players[i]; 

            if(addressToPlayer[playerAddress].numberSelected == numberPrizeGenerated){
                winners.push(playerAddress);
                count++;
            }
        }

        if(count != 0){
            uint256 winnerEtherAmount = totalBet / count;
            for(uint256 j = 0; j < count; j++) {
                address payable payTo = payable(winners[j]);
                if(payTo != address(0)) {
                    payTo.transfer(winnerEtherAmount);
                }
            }
        }
    }

    function generateWinnerNumber() private {
        uint256 numberPrize = (block.number + block.timestamp) % 10 + 1;
        rewardWinner(uint256(numberPrize));
    }

}