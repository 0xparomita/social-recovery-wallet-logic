# Social Recovery Wallet

A professional-grade implementation of a self-custodial smart contract wallet. This repository solves the "lost seed phrase" problem by decoupling ownership from a single private key. If the owner loses access, a threshold of trusted "Guardians" (friends, family, or hardware wallets) can vote to point the wallet to a new owner address.

## Core Features
* **Guardian-Based Security:** $M$-of-$N$ threshold to trigger a recovery event.
* **Recovery Delay:** Optional time-lock to prevent "Guardian attacks," allowing the original owner to cancel a malicious recovery.
* **Non-Custodial:** Guardians never have access to the funds; they only have the power to reset the owner.
* **Flat Structure:** Single-directory layout for the wallet logic and recovery state machine.

## Workflow
1. **Setup:** Owner deploys the wallet and designates 3-5 Guardians.
2. **Loss:** Owner loses their private key.
3. **Initiate:** A Guardian starts the recovery process, proposing a new address for the Owner.
4. **Confirm:** Other Guardians sign the proposal. Once the threshold is met, the Owner address is updated.

## Setup
1. `npm install`
2. Deploy `SocialRecoveryWallet.sol` with initial Guardian addresses.
