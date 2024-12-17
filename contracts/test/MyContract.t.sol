// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyContract.sol";

contract MyContractTest is Test {
    MyContract myContract;
    
    function setUp() public {
        myContract = new MyContract(0);
    }
    
    function testGetValue() public {
        assertEq(myContract.getValue(), 0);
    }
    
    function testSetValue() public {
        myContract.setValue(42);
        assertEq(myContract.getValue(), 42);
    }
}
