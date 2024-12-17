# Building dApps on Mandala Chain EVM: A Comprehensive Guide

## Introduction

The world of decentralized applications (dApps) is rapidly evolving, and Mandala Chain's EVM compatibility layer provides an exciting opportunity for Ethereum developers to leverage their existing skills in the Substrate ecosystem. This comprehensive guide will walk you through the entire process of building a dApp on Mandala Chain's EVM, from setting up your development environment to deploying your application. We'll use modern tools like Forge for smart contract development and Vue.js for the frontend, making the development process both efficient and enjoyable.

## Table of Contents
1. Understanding Mandala Chain EVM
2. Setting Up the Development Environment
3. Local Network Setup with Zombienet
4. Smart Contract Development with Forge
5. Deploying to Mandala Chain
6. Building the Frontend with Vue.js
7. Testing and Debugging
8. Best Practices and Optimization
9. Maintenance and Updates

## 1. Understanding Mandala Chain EVM

Mandala Chain's EVM compatibility is achieved through the Frontier pallet, which allows Substrate-based chains to execute Ethereum-style smart contracts. This means you can:
- Deploy Solidity smart contracts
- Use familiar Ethereum development tools
- Interact with contracts using standard Web3 libraries
- Leverage existing Ethereum development knowledge

Key differences from Ethereum:
- Different network configuration
- Substrate-specific features availability
- Cross-chain capabilities through Substrate infrastructure

## 2. Setting Up the Development Environment

### Installing Required Tools

First, let's install Foundry (which includes Forge):
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Verify the installation:
```bash
forge --version
cast --version
anvil --version
```

### Additional Dependencies
Install these essential tools:
```bash
# Node.js and npm (for Vue.js development)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Rust (for running Polkadot nodes)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## 3. Local Network Setup with Zombienet

Zombienet allows you to run a local Polkadot network for development and testing.

### Setting up Zombienet

1. Create a binaries directory and download required files:
```bash
mkdir -p binaries

# Download Polkadot binaries
wget https://github.com/paritytech/polkadot/releases/download/<version>/polkadot -O binaries/polkadot
chmod +x binaries/polkadot

# Download Zombienet binary
wget https://github.com/paritytech/zombienet/releases/download/<version>/zombienet-linux -O binaries/zombienet
chmod +x binaries/zombienet
```

2. Run Zombienet:
```bash
cd zombienet
./run.sh local
```

## 4. Smart Contract Development with Forge

### Creating a New Project
```bash
forge init my-polkadot-dapp
cd my-polkadot-dapp
```

### Writing the Smart Contract

Create `src/MyContract.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MyContract {
    int32 private value;
    
    // Event to emit when the value changes
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
```

### Writing Tests

Create `test/MyContract.t.sol`:
```solidity
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
    
    function testMultipleSetValue() public {
        myContract.setValue(42);
        myContract.setValue(-10);
        assertEq(myContract.getValue(), -10);
    }
}
```

Run the tests:
```bash
forge test
```

## 5. Deploying to Mandala Chain

### Preparing for Deployment

1. Create a deployment script in `script/MyContract.s.sol`:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/MyContract.sol";

contract MyContractScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        MyContract myContract = new MyContract(0);
        
        vm.stopBroadcast();
    }
}
```

2. Create `.env` file:
```env
PRIVATE_KEY=your_private_key_here
RPC_URL=your_mandala_rpc_url
```

3. Deploy the contract:
```bash
forge script script/MyContract.s.sol:MyContractScript --rpc-url $RPC_URL --broadcast
```

## 6. Building the Frontend with Vue.js

### Setting Up Vue Project

1. Create a new Vue project:
```bash
npm create vue@latest my-polkadot-dapp-frontend
cd my-polkadot-dapp-frontend
npm install
```

2. Install Web3 dependencies:
```bash
npm install ethers@5.7.2 web3modal
```

### Creating the dApp Interface

Create a new component `src/components/ContractInterface.vue`:
```vue
<template>
  <div class="contract-interface">
    <h1>MyContract dApp</h1>
    <div v-if="!isConnected">
      <button @click="connectWallet">Connect Wallet</button>
    </div>
    <div v-else>
      <p>Current Value: {{ value }}</p>
      <div class="input-group">
        <input 
          type="number" 
          v-model="newValue" 
          placeholder="Enter new value"
        >
        <button @click="setValue">Set Value</button>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers';
import MyContractABI from '../artifacts/MyContract.json';

export default {
  name: 'MyContractApp',
  data() {
    return {
      value: 0,
      newValue: '',
      isConnected: false,
      contract: null,
      provider: null,
      signer: null
    };
  },
  methods: {
    async connectWallet() {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        const signer = provider.getSigner();
        
        this.contract = new ethers.Contract(
          'YOUR_CONTRACT_ADDRESS',
          MyContractABI.abi,
          signer
        );
        
        this.isConnected = true;
        this.provider = provider;
        this.signer = signer;
        
        await this.updateValue();
      } catch (error) {
        console.error('Error connecting wallet:', error);
      }
    },
    
    async updateValue() {
      if (this.contract) {
        const currentValue = await this.contract.getValue();
        this.value = currentValue.toString();
      }
    },
    
    async setValue() {
      if (this.contract && this.newValue !== '') {
        try {
          const tx = await this.contract.setValue(parseInt(this.newValue));
          await tx.wait();
          await this.updateValue();
          this.newValue = ''; // Clear input after successful update
        } catch (error) {
          console.error('Error setting value:', error);
        }
      }
    }
  }
};
</script>

<style scoped>
.contract-interface {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  text-align: center;
}

.input-group {
  margin: 20px 0;
  display: flex;
  justify-content: center;
  gap: 10px;
}

input {
  padding: 8px;
  font-size: 16px;
  width: 150px;
}

button {
  padding: 10px 20px;
  font-size: 16px;
  cursor: pointer;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
}

button:hover {
  background-color: #45a049;
}
</style>
```

## 7. Testing and Debugging

### Smart Contract Testing
- Use Forge's built-in testing capabilities
- Test all contract functions
- Test edge cases and error conditions
- Use event logs for debugging

### Frontend Testing
- Test wallet connection
- Test contract interactions
- Test error handling
- Test UI responsiveness

### Integration Testing
- Test complete workflow
- Test network interactions
- Test transaction handling
- Test state updates

## 8. Best Practices and Optimization

### Smart Contract Best Practices
- Keep contracts simple and focused
- Minimize storage operations
- Use events for important state changes
- Follow security best practices

### Frontend Best Practices
- Handle network changes gracefully
- Provide clear user feedback
- Implement proper error handling
- Use loading states for transactions

### Gas Optimization
- Batch operations when possible
- Optimize storage usage
- Use appropriate data types
- Minimize contract complexity

## 9. Maintenance and Updates

### Monitoring
- Monitor contract usage
- Track transaction success rates
- Monitor gas costs
- Track user interactions

### Upgrades
- Plan for contract upgrades
- Implement proper version control
- Maintain comprehensive documentation
- Test upgrades thoroughly

### Security
- Regular security audits
- Monitor for vulnerabilities
- Keep dependencies updated
- Implement emergency stops if needed

## Conclusion

Building dApps on Polkadot's EVM allows developers to leverage their Ethereum development experience while taking advantage of Polkadot's unique features. By following this guide and best practices, you can create robust and efficient dApps that benefit from both ecosystems.

## Common Issues and Troubleshooting

1. Network Connection Issues
   - Verify RPC endpoint configuration
   - Check network status
   - Confirm wallet network settings

2. Transaction Failures
   - Check gas settings
   - Verify account balance
   - Review transaction parameters

3. Contract Deployment Issues
   - Verify contract compilation
   - Check deployment parameters
   - Confirm network configuration

4. Frontend Integration Problems
   - Verify contract ABI
   - Check contract address
   - Confirm Web3 provider setup

## Resources and References

- [Substrate Documentation](https://docs.substrate.io/)
- [Foundry Book](https://book.getfoundry.sh/)
- [Vue.js Documentation](https://vuejs.org/)
- [ethers.js Documentation](https://docs.ethers.io/)
- [Web3Modal Documentation](https://web3modal.com/)