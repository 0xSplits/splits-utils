// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {DistributeWrapper} from "../src/DistributeWrapper.sol";

contract DistributeWrapperScript is Script {
    using stdJson for string;

    address splitMain;

    function run() public returns (DistributeWrapper wrapper) {
        // https://book.getfoundry.sh/cheatcodes/parse-json
        string memory json = readInput("inputs");

        splitMain = json.readAddress(".splitMain");

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privKey);

        wrapper = new DistributeWrapper{salt: keccak256("0xSplits.distributeWrapper.v1")}({_splitMain: splitMain});

        vm.stopBroadcast();

        console2.log("DistributeWrapper Deployed:", address(wrapper));
    }

    function readInput(string memory input) internal view returns (string memory) {
        string memory inputDir = string.concat(vm.projectRoot(), "/script/input/");
        string memory chainDir = string.concat(vm.toString(block.chainid), "/");
        string memory file = string.concat(input, ".json");
        return vm.readFile(string.concat(inputDir, chainDir, file));
    }
}
