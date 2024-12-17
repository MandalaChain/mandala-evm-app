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
