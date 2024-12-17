# Step-by-Step Testing Guide for Mandala Chain EVM dApp

## Initial Repository Setup

1. Create and initialize the monorepo:
```bash
# Create the root directory
mkdir mandala-evm-dapp
cd mandala-evm-dapp

# Initialize git
git init

# Create basic structure
mkdir contracts frontend
touch README.md
```

2. Create the README.md:
```markdown
# Mandala Chain EVM dApp

A monorepo containing a full-stack dApp running on Mandala Chain's EVM.

## Structure
- `/contracts`: Solidity smart contracts and deployment scripts
- `/frontend`: Vue.js frontend application

## Quick Start

### Prerequisites
- Foundry (Forge)
- Node.js & npm
- Polkadot binaries (for Substrate/Zombienet)
- Zombienet

### Contracts
```bash
cd contracts
forge build
forge test
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```
```

## Smart Contract Setup

3. Set up the contracts directory:
```bash
cd contracts
forge init
rm -rf src/* test/*  # Remove default files
```

4. Create contract in `contracts/src/MyContract.sol`:
```solidity
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
```

5. Create test in `contracts/test/MyContract.t.sol`:
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
}
```

6. Create deployment script in `contracts/script/MyContract.s.sol`:
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
        console.log("Contract deployed at:", address(myContract));
        vm.stopBroadcast();
    }
}
```

## Frontend Setup

7. Create Vue project:
```bash
cd ../frontend
npm create vue@latest .
# Select the following options:
# ✔ Add TypeScript? Yes
# ✔ Add JSX Support? No
# ✔ Add Vue Router? Yes
# ✔ Add Pinia? No
# ✔ Add Vitest? Yes
# ✔ Add End-to-End Testing? No
# ✔ Add ESLint? Yes
# ✔ Add Prettier? Yes

npm install
npm install ethers@5.7.2 @ethersproject/providers
```

8. Create component in `frontend/src/components/ContractInterface.vue` (use the Vue component from the guide)

## Testing Checklist

### Smart Contract Tests
```bash
cd ../contracts

# Run tests
forge test -vv

# Check test coverage
forge coverage

# Try deployment script locally
forge script script/MyContract.s.sol:MyContractScript --fork-url http://localhost:8545 --broadcast -vvvv
```

### Frontend Tests
```bash
cd ../frontend

# Run Vue dev server
npm run dev

# Test compilation
npm run build

# Run unit tests
npm run test:unit
```

### Integration Testing

1. Local Network Testing:
```bash
# Terminal 1: Run local Mandala Chain node using Zombienet
cd zombienet
./run.sh local

# Terminal 2: Deploy contract
cd contracts
forge script script/MyContract.s.sol:MyContractScript --rpc-url http://localhost:8545 --broadcast -vvvv

# Terminal 3: Run frontend
cd frontend
npm run dev
```

2. Manual Testing Checklist:
- [ ] Connect wallet to Mandala Chain network
- [ ] Contract deployment successful
- [ ] Contract address logged correctly
- [ ] Frontend can connect to wallet
- [ ] Can read initial value
- [ ] Can set new value
- [ ] Events are emitted correctly
- [ ] Error handling works as expected

## Common Issues and Solutions

1. Contract Deployment Issues:
- Check if Mandala Chain network is running
- Verify account has sufficient funds
- Confirm RPC URL is correct
- Ensure correct network configuration for Mandala Chain

2. Frontend Connection Issues:
- Verify contract address is updated in the frontend
- Check if MetaMask is connected to Mandala Chain network
- Confirm ABI is correctly imported
- Verify Mandala Chain network configuration in MetaMask

3. Testing Issues:
- Make sure Forge is up to date
- Verify test network is running
- Check gas price settings for Mandala Chain

## Next Steps

After successful testing:

1. Document any issues found
2. Update README with Mandala Chain deployment addresses
3. Add environment setup instructions
4. Create deployment documentation for Mandala Chain
5. Add CI/CD configuration if needed

## Additional Mandala Chain Considerations

1. Network Configuration:
- Verify correct RPC endpoints
- Configure appropriate gas settings
- Set up proper network identifiers

2. Wallet Setup:
- Add Mandala Chain network to MetaMask
- Configure correct chain ID
- Set appropriate gas token

3. Deployment Verification:
- Use Mandala Chain block explorer
- Verify contract on the network
- Check transaction receipts