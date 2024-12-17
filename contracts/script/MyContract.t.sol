// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MyContract.sol";

contract MyContractScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        MyContract myContract = new MyContract(0);
        console.log("Contract deployed at:", address(myContract));
        vm.stopBroadcast();
    }
}