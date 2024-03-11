// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract TrueHelperConfig is Script {
    struct TrueNetworkConfig {
        uint256 entranceFee;
        uint256 timeInterval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionID;
        uint32 callbackGasLimit;
    }

    TrueNetworkConfig public activeTrueNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeTrueNetworkConfig = getSepoliaTrueETHConfig();
        } else {
            activeTrueNetworkConfig = getOrCreateTrueAnvilConfig();
        }
    }

    function getSepoliaTrueETHConfig()
        public
        pure
        returns (TrueNetworkConfig memory)
    {
        return
            TrueNetworkConfig({
                entranceFee: 0.01 ether,
                timeInterval: 30,
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionID: 0, // will update with our subID
                callbackGasLimit: 500000 // 500,000
            });
    }

    function getOrCreateTrueAnvilConfig()
        public
        returns (TrueNetworkConfig memory)
    {
        if (activeTrueNetworkConfig.vrfCoordinator != address(0)) {
            return activeTrueNetworkConfig;
        }

        uint96 baseFee = 0.25 ether; // 0.25 LINK this is because, VRF transactions are done in LINK
        uint96 gasPriceLink = 1e9; // 1 gwei of LINK

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        vm.stopBroadcast();

        return
            TrueNetworkConfig({
                entranceFee: 0.01 ether,
                timeInterval: 30,
                vrfCoordinator: address(vrfCoordinatorMock),
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionID: 0, // deploy script will provide this!
                callbackGasLimit: 500000 // 500,000
            });
    }
}
