// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {TrueHelperConfig} from "./TrueHelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateTrueSubscription is Script {
    function createTrueSubscriptionUsingTrueConfig() public returns (uint64) {
        TrueHelperConfig trueHelperConfig = new TrueHelperConfig();
        (, , address vrfCoordinator, , , ) = trueHelperConfig
            .activeTrueNetworkConfig();
        return createTrueSubscription(vrfCoordinator);
    }

    function createTrueSubscription(
        address vrfCoordinator
    ) public returns (uint64) {
        console2.log("Creating True subscription on ChainID: ", block.chainid);
        vm.startBroadcast();
        uint64 trueSubID = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console2.log("Your true sub ID is: ", trueSubID);
        return trueSubID;
    }

    function run() external returns (uint64) {
        return createTrueSubscriptionUsingTrueConfig();
    }
}
