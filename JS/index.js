const { ethers } = require("ethers");

      function createAccount() {
        const root = ethers.Wallet.createRandom();
        return root.mnemonic.phrase
    }

    module.exports = {createAccount };