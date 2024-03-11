// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TrueRaffle} from "../../src/TrueRaffle.sol";
import {DeployTrueRaffle} from "../../script/DeployTrueRaffle.s.sol";
import {TrueHelperConfig} from "../../script/TrueHelperConfig.s.sol";

contract TrueRaffleTest is Test {
    TrueRaffle trueRaffle;
    TrueHelperConfig trueHelperConfig;

    uint256 entranceFee;
    uint256 timeInterval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionID;
    uint32 callbackGasLimit;

    address public player = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

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
    }

    function testTrueRaffleInitialStateIsOpen() public view {
        assert(
            trueRaffle.getTrueRaffleState() == TrueRaffle.TrueRaffleState.Open
        );
    }
}
