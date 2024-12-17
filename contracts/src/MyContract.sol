// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MyContract {
    int32 private value;
    
    event ValueChanged(int32 newValue);
    
    constructor(int32 initValue) {
        value = initValue;
    }
    
    function getValue() public view returns (int32) {
        return value;
    }
    
    function setValue(int32 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }
}
