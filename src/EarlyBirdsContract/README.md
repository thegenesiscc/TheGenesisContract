# EarlyBirds Contract

## Overview

The `EarlyBirds` contract is an Ethereum-based smart contract designed to provide registration and activity management functionalities for early participants. The contract allows users to register during the activity period and manage funds for registration and withdrawal.

## Features

- **Registration**: Users can register during the activity by paying a fixed registration fee.
- **Activity Management**: The contract owner can start and pause the activity.
- **Fund Withdrawal**: The contract owner can withdraw BNB or ERC20 tokens from the contract.

## Contract Structure

### Main Functions

1. **Registration Function**:
   - Users register by paying a registration fee (0.01 BNB).
   - The contract records the participant's address and maintains a list of participants.

2. **Activity Management**:
   - The contract owner can start and pause the activity.
   - Users can only register when the activity is active.

3. **Withdrawal Function**:
   - The contract owner can withdraw funds from the contract.
   - The withdrawal function allows transferring BNB or ERC20 tokens to a specified address.

### Events

- `Registered(address indexed participant)`: Triggered when a user successfully registers.
- `ActivityStarted()`: Triggered when the activity starts.
- `ActivityPaused()`: Triggered when the activity is paused.
- `Withdraw(address indexed to,address indexed token, uint256 _value)`: Triggered when funds are withdraw.


## Usage Instructions

### Deploying the Contract

Before deploying the contract, ensure you have [Foundry](https://book.getfoundry.sh/) installed.

1. Clone the project:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install dependencies:
   ```bash
   forge install
   ```

3. Deploy the contract:
   ```bash
   forge create src/EarlyBirdsContract/EarlyBirds.sol:EarlyBirds --constructor-args <owner-address>
   ```

### Testing the Contract

The contract includes a series of test cases to ensure its functionality.

Run the tests:
```bash
forge test
```

## License

This project is licensed under the MIT License. For more details, please refer to the [LICENSE](LICENSE) file.