// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TrueRaffle} from "../../src/TrueRaffle.sol";
import {DeployTrueRaffle} from "../../script/DeployTrueRaffle.s.sol";
import {TrueHelperConfig} from "../../script/TrueHelperConfig.s.sol";

contract TrueRaffleTest is Test {
    /* Events */

    event EnteredTrueRaffle(address indexed TruePlayer);
    event PickedTrueWinner(address indexed TrueWinner);

    TrueRaffle trueRaffle;
    TrueHelperConfig trueHelperConfig;

    uint256 entranceFee;
    uint256 timeInterval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionID;
    uint32 callbackGasLimit;

    address public player = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10e18;

    function setUp() external {
        DeployTrueRaffle trueDeployer = new DeployTrueRaffle();
        (trueRaffle, trueHelperConfig) = trueDeployer.run();

        (
            entranceFee,
            timeInterval,
            vrfCoordinator,
            gasLane,
            subscriptionID,
            callbackGasLimit
        ) = trueHelperConfig.activeTrueNetworkConfig();
        vm.deal(player, STARTING_USER_BALANCE);
    }

    function testTrueRaffleInitialStateIsOpen() public view {
        assert(
            trueRaffle.getTrueRaffleState() == TrueRaffle.TrueRaffleState.Open
        );
    }

    //////////////////////////
    // enterTrueRaffle  //////
    //////////////////////////

    function testEnterTrueRaffleRevertsWhenNotEnoughETH() public {
        // arrange
        vm.startPrank(player);
        // act/assert
        vm.expectRevert(TrueRaffle.TrueRaffle__NotEnoughETHSent.selector);
        trueRaffle.enterTrueRaffle();
    }

    function testPlayersAreAddedToTruePlayersArray() public {
        // arrange
        vm.startPrank(player);
        // act
        trueRaffle.enterTrueRaffle{value: entranceFee}();
        address truePlayerAdded = trueRaffle.getTruePlayer(0);
        // assert
        assert(truePlayerAdded == player);
    }

    function testEmitEventsWhenTrueRaffleEntered() public {
        vm.startPrank(player);
        vm.expectEmit(true, false, false, false, address(trueRaffle));
        emit EnteredTrueRaffle(player);
        trueRaffle.enterTrueRaffle{value: entranceFee}();
    }
}
