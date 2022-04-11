//SPDX-License-Identifier: Unlicense
pragma solidity >=0.7.0 <0.9.0;

// This contract is the infrastructure for a game
// The game has a joining fee of 25 ether
// The game has one loser, and the rest of the players are winners
// When the game ends, the sum of the joining fee is distributed to all of the winners
// The game has functionality that upgrades a player's level
// This is just a sandbox, and I am excited to add new functionality


contract myGame {
    uint public playerCount = 0;
    uint public pot = 0;

    address public dealer;

    Player[] public playersInGame;

    mapping (address => Player) public players;

    enum Level {Novice, Intermediate, Advanced}

    struct Player {
        address playerAddress;
        Level playerLevel;
        string firstName;
        string lastName;
        uint createdTime;
    }

    constructor(){
        dealer = msg.sender;
    }

    function addPlayer(string memory firstName, string memory lastName) private {
        Player memory newPlayer = Player(msg.sender, Level.Novice, firstName, lastName, block.timestamp);
        players[msg.sender] = newPlayer;
        playersInGame.push(newPlayer);
    }

    function getPlayerLevel(address playerAddress) public view returns(Level) {
        Player storage player = players[playerAddress];
        return player.playerLevel;
    }

    function changePlayerLevel(address playerAddress) public {
        Player storage player = players[playerAddress];
        if (block.timestamp >= player.createdTime + 20) {
            player.playerLevel = Level.Intermediate;
        }
    }

    function joinGame(string memory firstName, string memory lastName) payable public{
        require(msg.value == 25 ether, "The joining fee is 25 ether");
        if (payable(dealer).send(msg.value)) {
            addPlayer(firstName, lastName);
            playerCount += 1;
            pot += 25;
        }
    }

    function payOutWinners(address loserAddress) payable public {
        require(msg.sender == dealer, "Only the dealer can pay out the winners.");
        require(msg.value == pot * (1 ether));
        uint payoutPerWinner = msg.value / (playerCount - 1);
        for (uint i=0;i<playersInGame.length; i++) {
            address currentPlayerAddress = playersInGame[i].playerAddress;
            if (currentPlayerAddress != loserAddress) {
                payable(currentPlayerAddress).transfer(payoutPerWinner);
            }
        }
    }
}
