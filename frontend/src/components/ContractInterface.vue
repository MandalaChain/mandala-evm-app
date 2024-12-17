<template>
  <div class="contract-interface">
    <h1>MyContract dApp</h1>
    <div v-if="!isConnected">
      <button @click="connectWallet">Connect Wallet</button>
    </div>
    <div v-else>
      <p>Current Value: {{ value }}</p>
      <div class="input-group">
        <input type="number" v-model="newValue" placeholder="Enter new value" />
        <button @click="setValue">Set Value</button>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import { ethers } from 'ethers'
import type { ExternalProvider } from '@ethersproject/providers'
import MyContractABI from '../artifacts/MyContract.json'

declare global {
  interface Window {
    ethereum?: ExternalProvider
  }
}

export default defineComponent({
  name: 'MyContractApp',
  data() {
    return {
      value: 0,
      newValue: '',
      isConnected: false,
      contract: null as ethers.Contract | null,
      provider: null as ethers.providers.Web3Provider | null,
      signer: null as ethers.Signer | null,
    }
  },
  methods: {
    async connectWallet() {
      try {
        if (!window.ethereum) {
          throw new Error('MetaMask not installed!')
        }
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        await provider.send('eth_requestAccounts', [])
        const signer = provider.getSigner()

        this.contract = new ethers.Contract('YOUR_CONTRACT_ADDRESS', MyContractABI.abi, signer)

        this.isConnected = true
        this.provider = provider
        this.signer = signer

        await this.updateValue()
      } catch (error) {
        console.error('Error connecting wallet:', error)
      }
    },

    async updateValue() {
      if (this.contract) {
        const currentValue = await this.contract.getValue()
        this.value = currentValue.toString()
      }
    },

    async setValue() {
      if (this.contract && this.newValue !== '') {
        try {
          const tx = await this.contract.setValue(parseInt(this.newValue))
          await tx.wait()
          await this.updateValue()
          this.newValue = '' // Clear input after successful update
        } catch (error) {
          console.error('Error setting value:', error)
        }
      }
    },
  },
})
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
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 4px;
}

button:hover {
  background-color: #45a049;
}
</style>
