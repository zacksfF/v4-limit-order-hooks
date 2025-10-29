# 🦄 v4-limit-order-hook

Autonomous on-chain limit orders using Uniswap v4 Hooks. No keepers, no bots—just smart contracts.

## Overview

This project demonstrates how to implement self-executing limit orders directly on-chain using Uniswap v4's Hook architecture. Orders automatically execute when the target price is reached.

**📖 Full technical breakdown:** [Read the Medium article](https://medium.com/@zakariasaif/when-dexs-get-smart-building-autonomous-limit-orders-on-uniswap-v4-50ea53cecf13)

## Features

- ✅ Create limit orders with custom price targets
- ✅ Automatic execution when tick threshold is met
- ✅ Double-execution prevention
- ✅ Multiple orders per pool support
- ✅ Dynamic fee adjustment example

## Tech Stack

- **Solidity** ^0.8.24
- **Foundry** for testing and deployment
- **Uniswap v4 Core** for pool management

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/zacksfF/v4-limit-order-hooks.git
cd v4-limit-order-hooks

# Install dependencies
forge install

# Build the project
forge build
```

### Running Tests

```bash
forge test -vvv
```

Expected output:
```
Ran 5 tests for test/LimitOrderHook.t.sol:LimitOrderHookTest
[PASS] testAlreadyExecutedOrderDoesNotDoubleExecute() (gas: 184660)
[PASS] testEdgeCases() (gas: 428904)
[PASS] testMultipleOrdersInOnePool() (gas: 310838)
[PASS] testPriceNotReachedYet() (gas: 178390)
[PASS] testSingleOrderExec() (gas: 181284)

Suite result: ok. 5 passed; 0 failed; 0 skipped
```

## How It Works

1. **Create Order**: User specifies token pair, amount, and target tick
2. **Monitor**: Hook listens to all swaps in the pool via `afterSwap()`
3. **Execute**: When `currentTick >= targetTick`, order is marked executed
4. **Prevent Doubles**: Executed flag prevents re-execution

See the [Medium article](https://medium.com/@zakariasaif/when-dexs-get-smart-building-autonomous-limit-orders-on-uniswap-v4-50ea53cecf13) for detailed implementation breakdown.

## ⚠️ Disclaimer

This is a **research prototype** for educational purposes. It is NOT production-ready and has not been audited. Do not use with real funds.

Missing features:
- Actual swap execution
- Fund custody mechanism
- Order cancellation
- Gas optimization
- Security audit

## License

MIT

## Contributing

PRs welcome! Feel free to fork, experiment, and submit improvements.

## Contact

Questions? Reach out on [Medium](https://medium.com/@zakariasaif) or open an issue.

---

**Built with ⚡ on Uniswap v4**

