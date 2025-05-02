# 🧱 ConsensusCoin

**ConsensusCoin** is a minimalist, burn-to-finalize smart contract deployed on the Polygon blockchain. It provides a permanent, decentralized way to record irreversible agreement on any named topic, action, or concept.

---

## ✨ Core Features

* 📅 **One-time Mint**: Anyone can mint up to 100,000,000 tokens under a unique name for a fixed fee of 1 POL.
* 🔥 **Burn-to-Reach-Consensus**: Tokens must be burned by holders. When the total supply reaches 0, consensus is permanently recorded.
* ⚖️ **On-chain Uniswap Salt**: ETH/USDC and BTC/USDC prices from Uniswap V3 are used to auto-generate a unique salt for each name.
* ⛔️ **No Admins. No Upgrades. No Governance.** Just pure irreversible logic.
* 🚀 **Every Mint Pays the Creator**: Each mint transaction (1 POL) is automatically forwarded to the protocol creator.

---

## 📄 Contract Details

* **Network**: Polygon Mainnet
* **Address**: [`0x501cbA7B8a30D7cF319F90537a12ce9C7B8FC105`](https://polygonscan.com/address/0x501cbA7B8a30D7cF319F90537a12ce9C7B8FC105)
* **Deployer/Creator**: [`0x0F6dbb5B71372aB1d77Ed67D1260083cF9f07476`](https://polygonscan.com/address/0x0F6dbb5B71372aB1d77Ed67D1260083cF9f07476)
* **License**: MIT

---

## ⚙️ How It Works

### ✅ Mint

```solidity
mint("TRUTH", 1000000, 0xRecipientWallet)
// Requires: msg.value == 1 ether (1 POL)
```

* Contract fetches ETH & BTC prices from Uniswap
* Computes salt: `salt = bytes32(ethPrice + btcPrice)`
* setId = `keccak256(name + salt)`
* Mints tokens to `to`

### ✉️ Burn

```solidity
burn("TRUTH", 1000000)
```

* Reduces sender's balance
* Reduces totalSupply
* If totalSupply == 0:

  * Records `consensusReached[setId] = true`
  * Emits `Consensus(name, setId)` event

---

## 💼 Use Cases

* Shareholder agreement: mint shares, burn to vote
* Public commitments: burn to confirm fulfillment
* Digital rituals: burn to symbolize closure
* Recordkeeping: create events that lock forever

---

## 🎓 Deploy Your Own

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Paste `ConsensusCoin.sol`
3. Compile with `0.8.29`
4. Deploy with **Injected Web3** (MetaMask)
5. Leave constructor blank (wallet is hardcoded)

---

## 🔧 Dev Tools

* `balanceOf(name, address)`
* `hasConsensus(name)`

---

## 🔗 Links

* [PolygonScan Contract](https://polygonscan.com/address/0x501cbA7B8a30D7cF319F90537a12ce9C7B8FC105)
* [Verified Source Code](https://polygonscan.com/address/0x501cbA7B8a30D7cF319F90537a12ce9C7B8FC105#code)

---

## ✍️ Contribute

Pull requests welcome. If you build a frontend or integrate this into your own project, let us know!
