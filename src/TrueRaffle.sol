// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/** Imports */

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

/**
 * @title TrueRaffle
 * @author yeahChibyke
 * @notice Raffle system contract
 * @dev implements Chainlink VRFv2
 */
contract TrueRaffle is VRFConsumerBaseV2 {
    /** Errors */

    error TrueRaffle__NotEnoughETHSent();
    error TrueRaffle__TransferFailed();
    error TrueRaffle__TrueRaffleNotOpen();
    error TrueRaffle__UpKeepNotNeeded(
        uint256 currentTrueBalance,
        uint256 numTruePlayers,
        uint256 trueRaffleState
    );

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
    event PickedTrueWinner(address indexed TrueWinner);

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
        // check msg.value is not lesser than i_TrueentranceFee
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

    /**
     * @dev Chainlink Automation nodes call this function to check if it's time to perform an upKeep
     * The following should be true for the check to return true:
     *    time interval has passed between raffle runs
     *    the raffle is in an Open state
     *    the contract has ETH (i.e., players)
     *    (Implicit) the subscription is funded with LINK
     */
    function checkUpKeep(
        bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - s_TrueLastTimeStamp) >=
            i_TrueTimeInterval;
        bool isOpen = TrueRaffleState.Open == s_TrueRaffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_TruePlayers.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        (bool upKeepNeeded, ) = checkUpKeep("");

        if (!upKeepNeeded) {
            revert TrueRaffle__UpKeepNotNeeded(
                address(this).balance,
                s_TruePlayers.length,
                uint256(s_TrueRaffleState)
            );
        }

        // set state to calculating
        s_TrueRaffleState = TrueRaffleState.Calculating;

        /*uint256 requestId =*/ i_TrueVRFCoordinator.requestRandomWords(
            i_TrueGasLane, // gasLane
            i_TrueSubscriptionID,
            TRUE_REQUESTCONFIRMATIONS,
            i_TrueCallbackGasLimit,
            TRUE_NUMWORDS
        );
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfTrueWinner = randomWords[0] % s_TruePlayers.length;
        address payable trueWinner = s_TruePlayers[indexOfTrueWinner];

        // equate the current winner to true winner
        s_TrueRecentWinner = trueWinner;
        // set state back to open
        s_TrueRaffleState = TrueRaffleState.Open;
        // reset players array
        s_TruePlayers = new address payable[](0);
        // reset timestamp
        s_TrueLastTimeStamp = block.timestamp;

        (bool sent, ) = trueWinner.call{value: address(this).balance}("");
        if (!sent) {
            revert TrueRaffle__TransferFailed();
        }

        emit PickedTrueWinner(trueWinner);
    }

    /** Getter Functions */

    function getEntranceFee() external view returns (uint256) {
        return i_TrueEntranceFee;
    }

    function getTrueRaffleState() external view returns (TrueRaffleState) {
        return s_TrueRaffleState;
    }

    function getTruePlayer(
        uint256 indexOfTruePlayer
    ) external view returns (address) {
        return s_TruePlayers[indexOfTruePlayer];
    }
}
