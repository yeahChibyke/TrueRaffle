// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

/** Imports */

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/** Errors */

error TrueRaffle__NotEnoughETHSent();
error TrueRaffle__TransferFailed();
error TrueRaffle__TrueRaffleNotOpen();

pragma solidity ^0.8.20;

/**
 * @title TrueRaffle
 * @author yeahChibyke
 * @notice Raffle system contract
 * @dev implements Chainlink VRFv2
 */
contract TrueRaffle is VRFConsumerBaseV2 {
    /** Type declarations */

    enum TrueRaffleState {
        Open, // 0
        Calculating // 1
    }

    /** State Variables */

    uint16 private constant TRUE_REQUESTCONFIRMATIONS = 3;
    uint32 private constant TRUE_NUMWORDS = 1;

    uint256 private immutable i_TrueEntranceFee;
    // @dev: duration of the lottery in seconds
    uint256 private immutable i_TrueTimeInterval;
    // @dev: Chainlink VRF
    VRFCoordinatorV2Interface private immutable i_TrueVRFCoordinator;
    bytes32 private immutable i_TrueGasLane;
    uint64 private immutable i_TrueSubscriptionID;
    uint32 private immutable i_TrueCallbackGasLimit;

    address payable[] private s_TruePlayers;
    uint256 private s_TrueLastTimeStamp;
    address private s_TrueRecentWinner;
    TrueRaffleState private s_TrueRaffleState;

    /** Events */

    event EnteredTrueRaffle(address indexed TruePlayer);

    constructor(
        uint256 entranceFee,
        uint256 timeInterval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionID,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_TrueEntranceFee = entranceFee;
        i_TrueTimeInterval = timeInterval;
        i_TrueVRFCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_TrueGasLane = gasLane;
        i_TrueSubscriptionID = subscriptionID;
        i_TrueCallbackGasLimit = callbackGasLimit;

        s_TrueLastTimeStamp = block.timestamp;
        s_TrueRaffleState = TrueRaffleState.Open;
    }

    function enterTrueRaffle() external payable {
        if (msg.value < i_TrueEntranceFee) {
            revert TrueRaffle__NotEnoughETHSent();
        }
        // check that TrueRaffle is open
        if (s_TrueRaffleState != TrueRaffleState.Open) {
            revert TrueRaffle__TrueRaffleNotOpen();
        }

        s_TruePlayers.push(payable(msg.sender));
        emit EnteredTrueRaffle(msg.sender);
    }

    function pickTrueWinner() external {
        // check to ensure adequate time has passed
        if ((block.timestamp - s_TrueLastTimeStamp) < i_TrueTimeInterval) {
            revert();
        }

        // set state to calculating
        s_TrueRaffleState = TrueRaffleState.Calculating;

        uint256 requestId = i_TrueVRFCoordinator.requestRandomWords(
            i_TrueGasLane, // gasLane
            i_TrueSubscriptionID,
            TRUE_REQUESTCONFIRMATIONS,
            i_TrueCallbackGasLimit,
            TRUE_NUMWORDS
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfTrueWinner = randomWords[0] % s_TruePlayers.length;
        address payable trueWinner = s_TruePlayers[indexOfTrueWinner];
        s_TrueRecentWinner = trueWinner;

        // set state back to open
        s_TrueRaffleState = TrueRaffleState.Open;

        (bool sent, ) = trueWinner.call{value: address(this).balance}("");
        if (!sent) {
            revert TrueRaffle__TransferFailed();
        }
    }

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_TrueEntranceFee;
    }
}
