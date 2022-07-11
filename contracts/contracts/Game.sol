// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract GameContract is ReentrancyGuard {
  using SafeMath for uint256;

  using Counters for Counters.Counter;
  Counters.Counter private _gameIds;

  event GetGameOutcome(GameOutcome);

  enum GameStatus {
    started,
    ongoing,
    ended
  }

  enum GameOutcome {
    draw,
    playerOne,
    playerTwo
  }

  //   Player 1 who creates game and player 2 is opponent
  struct Game {
    address playerOne;
    address playerTwo;
    uint256 stake;
    string gameCode;
    string beforeMatchDataURI;
    string afterMatchDataURI;
    GameStatus status;
    GameOutcome outcome;
  }

  mapping(address => uint256) public playerBalances;
  mapping(string => Game) public games;
  mapping(GameOutcome => string) public outcomes;

  constructor() {
    outcomes[GameOutcome.draw] = "draw";
    outcomes[GameOutcome.playerOne] = "playerOne";
    outcomes[GameOutcome.playerTwo] = "playerTwo";
  }

  function compareStrings(string memory a, string memory b)
    public
    view
    returns (bool)
  {
    return (keccak256(abi.encodePacked((a))) ==
      keccak256(abi.encodePacked((b))));
  }

  // Player 1 creates a game
  function startGame(
    string memory gameCode,
    string memory beforeMatchDataURI,
    address opponent,
    uint256 stake
  ) external {
    require(
      opponent != address(0x0) && opponent != msg.sender,
      "Enter a valid opponent adderess"
    );
    require(
      stake <= playerBalances[msg.sender],
      "Players funds are insufficient"
    );

    playerBalances[msg.sender] = playerBalances[msg.sender].sub(stake);

    games[gameCode].gameCode = gameCode;
    games[gameCode].playerOne = msg.sender;
    games[gameCode].playerTwo = opponent;
    games[gameCode].stake = stake;
    games[gameCode].status = GameStatus.started;
    games[gameCode].beforeMatchDataURI = beforeMatchDataURI;
  }

  //  Player 2 joins the game
  function participateGame(string memory gameCode) external {
    require(
      games[gameCode].playerTwo == msg.sender,
      "You are not Player 2 for this game"
    );
    require(
      games[gameCode].status == GameStatus.started,
      "Game not started or has already been participated in"
    );

    uint256 gameStake = games[gameCode].stake;
    require(
      gameStake <= playerBalances[msg.sender],
      "Player funds are insufficient"
    );

    playerBalances[msg.sender] = playerBalances[msg.sender].sub(gameStake);
    games[gameCode].status = GameStatus.ongoing;
  }

  //   finish the game
  function endGame(
    string memory gameCode,
    string memory afterMatchDataURI,
    string memory result
  ) external {
    require(
      games[gameCode].status == GameStatus.ongoing,
      "Match did not started or invalid code"
    );
    require(
      compareStrings(result, outcomes[GameOutcome.playerTwo]) ||
        compareStrings(result, outcomes[GameOutcome.draw]) ||
        compareStrings(result, outcomes[GameOutcome.playerOne]),
      "Invalid Result"
    );
    // Have to change this later
    // require(
    //   games[gameCode].playerOne == msg.sender,
    //   "Only Players can end the game"
    // );

    games[gameCode].status = GameStatus.ended;
    games[gameCode].afterMatchDataURI = afterMatchDataURI;

    address playerOne = games[gameCode].playerOne;
    address playerTwo = games[gameCode].playerTwo;

    uint256 gameStake = games[gameCode].stake;

    if (compareStrings(result, outcomes[GameOutcome.draw])) {
      games[gameCode].outcome = GameOutcome.draw;
      playerBalances[playerOne] = playerBalances[playerOne].add(gameStake);
      playerBalances[playerTwo] = playerBalances[playerTwo].add(gameStake);
    } else if (compareStrings(result, outcomes[GameOutcome.playerOne])) {
      games[gameCode].outcome = GameOutcome.playerOne;
      uint256 totalStakeWon = gameStake.mul(2);
      playerBalances[playerOne] = playerBalances[playerOne].add(totalStakeWon);
    } else if (compareStrings(result, outcomes[GameOutcome.playerTwo])) {
      games[gameCode].outcome = GameOutcome.playerTwo;
      uint256 totalStakeWon = gameStake.mul(2);
      playerBalances[playerTwo] = playerBalances[playerTwo].add(totalStakeWon);
    }
  }

  function withdraw() external nonReentrant {
    uint256 playerBalance = playerBalances[msg.sender];
    require(playerBalance > 0, "No balance");

    playerBalances[msg.sender] = 0;
    (bool success, ) = address(msg.sender).call{value: playerBalance}("");
    require(success, "withdraw failed to send");
  }

  function deposit() external payable {
    require(msg.value > 0, "Please Deposit a valid amount greater than zero");
    playerBalances[msg.sender] = playerBalances[msg.sender].add(msg.value);
  }

  function getPlayerBalance(address playerAddress)
    external
    view
    returns (uint256 playerBalance)
  {
    return playerBalances[playerAddress];
  }

  function getGameDetails(string memory gameCode)
    external
    view
    returns (string memory URI)
  {
    require(games[gameCode].status == GameStatus.started, "Invalid Code");
    return games[gameCode].beforeMatchDataURI;
  }
}
