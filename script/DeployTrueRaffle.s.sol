// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TrueRaffle} from "../src/TrueRaffle.sol";
import {Script} from "forge-std/Script.sol";
import {TrueHelperConfig} from "./TrueHelperConfig.s.sol";
import {CreateTrueSubscription} from "./TrueInteractions.s.sol";

contract DeployTrueRaffle is Script {
    function run() external returns (TrueRaffle, TrueHelperConfig) {
        TrueHelperConfig trueHelperConfig = new TrueHelperConfig();
        (
            uint256 entranceFee,
            uint256 timeInterval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionID,
            uint32 callbackGasLimit
        ) = trueHelperConfig.activeTrueNetworkConfig();

        if (subscriptionID == 0) {
            // I need to create a subscriptionID!
            CreateTrueSubscription createTrueSubscription = new CreateTrueSubscription();
            subscriptionID = createTrueSubscription.createTrueSubscription(
                vrfCoordinator
            );
        }

        vm.startBroadcast();
        TrueRaffle trueRaffle = new TrueRaffle(
            entranceFee,
            timeInterval,
            vrfCoordinator,
            gasLane,
            subscriptionID,
            callbackGasLimit
        );
        vm.stopBroadcast();

        return (trueRaffle, trueHelperConfig);
    }
}
