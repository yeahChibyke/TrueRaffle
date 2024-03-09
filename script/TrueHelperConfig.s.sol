// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

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
        view
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
        view
        returns (TrueNetworkConfig memory)
    {
        if (activeTrueNetworkConfig.vrfCoordinator != address(0)) {
            return activeTrueNetworkConfig;
        }
    }
}
