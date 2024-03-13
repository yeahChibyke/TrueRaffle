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
        } else if (block.chainid == 5) {
            activeTrueNetworkConfig = getGoerliTrueETHConfig();
        } else if (block.chainid == 43113) {
            activeTrueNetworkConfig = getAvaFujiTestnetTrueETHConfig();
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

    function getGoerliTrueETHConfig()
        public
        pure
        returns (TrueNetworkConfig memory)
    {
        return
            TrueNetworkConfig({
                entranceFee: 0.01 ether,
                timeInterval: 30,
                vrfCoordinator: 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D,
                gasLane: 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15,
                subscriptionID: 0,
                callbackGasLimit: 500000
            });
    }

    function getAvaFujiTestnetTrueETHConfig()
        public
        pure
        returns (TrueNetworkConfig memory)
    {
        return
            TrueNetworkConfig({
                entranceFee: 0.01 ether,
                timeInterval: 30,
                vrfCoordinator: 0x2eD832Ba664535e5886b75D64C46EB9a228C2610,
                gasLane: 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61,
                subscriptionID: 0,
                callbackGasLimit: 500000
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
