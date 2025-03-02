# Invitation Contract

## Overview

The Invitation Contract is a smart contract deployed on the Binance Smart Chain (BSC) that facilitates an invitation system. Users can bind their inviter and track their invitation relationships. The contract also integrates with a third-party team contract to check existing invitations.

## Features

- **Bind Invitation**: Users can bind their inviter by providing the inviter's address.
- **Admin Control**: Administrators can set the team contract address and enable or disable team contract checks.
- **Manual Inviter Setting**: Administrators can manually set an inviter for a specific user.
- **Query Current Inviter**: Users can query their current inviter, checking both the current contract and the team contract.
- **Total Counts**: The contract keeps track of the total number of inviters and invitees.

## Functions

### 1. `bindInvitation(address _inviter)`

- **Description**: Binds the caller (msg.sender) as an invitee to the specified inviter.
- **Parameters**:
  - `address _inviter`: The address of the inviter.
- **Requirements**:
  - The inviter address must not be zero or a contract address.
  - The caller must not already have an inviter.
  - The caller must not be the same as the inviter.
  - If team checks are enabled, the caller must not already be invited in the team contract.

### 2. `setTeamContract(address _teamContract)`

- **Description**: Allows the admin to set the address of the team contract.
- **Parameters**:
  - `address _teamContract`: The address of the team contract.

### 3. `setTeamCheckEnabled(bool _enabled)`

- **Description**: Allows the admin to enable or disable the team contract check.
- **Parameters**:
  - `bool _enabled`: A flag to enable or disable the check.

### 4. `getCurrentInviter(address _user)`

- **Description**: Returns the current inviter of the specified user, checking both the current contract and the team contract if enabled.
- **Parameters**:
  - `address _user`: The address of the user to query.

### 5. `setInviter(address _invitee, address[] calldata _inviterList)`

- **Description**: Allows the admin to set the inviter for a specific invitee.
- **Parameters**:
  - `address _invitee`: The address of the invitee.
  - `address[] calldata _inviterList`: An array of inviter addresses.

### 6. `adminSetInviter(address _invitee, address _inviter)`

- **Description**: Allows the admin to manually set an inviter for a specific user.
- **Parameters**:
  - `address _invitee`: The address of the invitee.
  - `address _inviter`: The address of the inviter.

### 7. `getTotalCounts()`

- **Description**: Returns the total number of inviters and invitees in the contract.

### 8. `withdraw(address _token)`

- **Description**: Allows the admin to withdraw assets from the contract.
- **Parameters**:
  - `address _token`: The address of the token to withdraw. Use `address(0)` for BNB.

## Security Considerations

- Ensure that the contract is thoroughly tested and audited before deployment.
- Consider implementing multi-signature wallets for critical operations.
- Regularly update the contract to address any potential vulnerabilities.

## License

This contract is licensed under the MIT License.
