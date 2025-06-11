# Energy Grid Monitoring & Theft Prevention System Smart Contract

A comprehensive blockchain-based smart contract solution for monitoring electricity consumption, detecting energy theft patterns through anomaly analysis, and implementing automated penalty enforcement across distributed smart grid networks.

## Overview

This smart contract provides a decentralized system for energy grid management with built-in theft detection capabilities. It enables utility companies to monitor smart meters, detect suspicious consumption patterns, and automatically enforce penalties for energy theft incidents.

## Key Features

### Smart Meter Management
- Register and manage smart meter installations
- Track property ownership and installation locations
- Enable/disable meter operations
- Monitor device operational status

### Consumption Monitoring
- Process real-time energy consumption data
- Maintain historical consumption logs
- Calculate baseline consumption patterns
- Track consumption anomalies and risk scores

### Theft Detection & Prevention
- Automated anomaly detection using consumption thresholds
- Risk severity classification (Normal, Low, Medium, High)
- Suspicious activity tracking and incident logging
- Automated penalty assessment and enforcement

### Financial Management
- Automated penalty collection system
- Treasury fund management
- Withdrawal capabilities for authorized administrators
- Transparent fee tracking and reporting

### Access Control
- Administrator privilege management
- Authorized operator system
- Property owner verification
- Secure role-based permissions

## System Architecture

### Data Structures

#### Smart Meter Registry
Stores comprehensive information about each registered smart meter:
- Property owner wallet address
- Physical installation address
- Baseline and current consumption readings
- Operational status and activity tracking
- Suspicious activity detection count

#### Historical Consumption Logs
Maintains detailed records of all consumption readings:
- Energy consumption values (kWh)
- Data collection timestamps
- Blockchain recording blocks
- Consumption anomaly risk scores

#### Security Incident Records
Tracks all detected theft incidents:
- Involved smart meter identification
- Incident detection block height
- Risk severity classification
- Financial penalty assessment
- Resolution status and completion

### Anomaly Detection Algorithm

The system uses a threshold-based approach to detect energy theft:

1. **Baseline Calculation**: Establishes normal consumption patterns
2. **Risk Score Computation**: Compares current usage to baseline
3. **Threshold Analysis**: Categorizes anomalies by severity
4. **Automated Response**: Triggers incident creation and penalty assessment

#### Risk Thresholds
- **Low Risk**: 50% above baseline (150% of normal)
- **Medium Risk**: 100% above baseline (200% of normal)
- **High Risk**: 200% above baseline (300% of normal)

#### Penalty Structure
- **Low Severity**: 1 STX (1,000,000 microSTX)
- **Medium Severity**: 5 STX (5,000,000 microSTX)
- **High Severity**: 10 STX (10,000,000 microSTX)

## Installation & Deployment

### Prerequisites
- Stacks blockchain network access
- Clarity smart contract deployment tools
- Administrative wallet with sufficient STX balance

### Deployment Steps
1. Deploy the contract to your chosen Stacks network
2. The deploying address automatically becomes the system administrator
3. Configure authorized operators using `authorize-system-operator`
4. Begin registering smart meters with `register-new-smart-meter`

## Usage Guide

### For System Administrators

#### Register New Smart Meters
```clarity
(register-new-smart-meter 'SP1ABC... "123 Main Street, City, State")
```

#### Authorize System Operators
```clarity
(authorize-system-operator 'SP2DEF...)
```

#### Withdraw Treasury Funds
```clarity
(withdraw-treasury-funds u5000000) ;; Withdraw 5 STX
```

### For Authorized Operators

#### Process Consumption Data
```clarity
(process-energy-consumption-data u1 u250) ;; Meter ID 1, 250 kWh
```

#### Enable/Disable Meters
```clarity
(disable-smart-meter-device u1)
(enable-smart-meter-device u1)
```

### For Property Owners

#### Resolve Theft Incidents
```clarity
(resolve-energy-theft-incident u1) ;; Pay penalty for incident ID 1
```

## API Reference

### Public Functions

#### Administrative Functions
- `authorize-system-operator(operator-wallet-address: principal)` - Grant operator privileges
- `revoke-system-operator-authorization(operator-wallet-address: principal)` - Remove operator privileges
- `register-new-smart-meter(property-owner-address: principal, installation-location: string-ascii)` - Register new meter
- `withdraw-treasury-funds(withdrawal-amount-microstx: uint)` - Withdraw treasury funds

#### Operational Functions
- `disable-smart-meter-device(meter-device-id: uint)` - Disable meter operations
- `enable-smart-meter-device(meter-device-id: uint)` - Enable meter operations
- `process-energy-consumption-data(meter-device-id: uint, consumption-reading-kwh: uint)` - Process consumption data
- `resolve-energy-theft-incident(incident-tracking-id: uint)` - Resolve theft incident with penalty payment

### Read-Only Functions

#### Data Query Functions
- `get-smart-meter-details(meter-device-id: uint)` - Retrieve meter information
- `get-consumption-history-record(meter-device-id: uint, reading-sequence-number: uint)` - Get consumption history
- `get-security-incident-information(incident-tracking-id: uint)` - Get incident details
- `get-system-overview-statistics()` - Get comprehensive system statistics

#### Verification Functions
- `check-operator-authorization-status(operator-address: principal)` - Check operator status
- `get-property-owner-meter-count(owner-address: principal)` - Get owner's meter count
- `get-current-anomaly-risk-score(meter-device-id: uint)` - Calculate current risk score
- `verify-smart-meter-ownership(meter-device-id: uint, claiming-owner-address: principal)` - Verify ownership

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ACCESS-DENIED | Insufficient privileges for operation |
| u101 | ENTITY-NOT-FOUND | Requested entity does not exist |
| u102 | DUPLICATE-REGISTRATION | Entity already registered |
| u103 | INVALID-INPUT-DATA | Input validation failed |
| u104 | INSUFFICIENT-BALANCE | Insufficient funds for operation |
| u105 | OPERATION-NOT-ALLOWED | Operation not permitted |
| u106 | METER-DISABLED | Smart meter is disabled |
| u107 | INCIDENT-ALREADY-RESOLVED | Security incident already resolved |
| u108 | INVALID-ADDRESS | Invalid wallet address format |
| u109 | UNAUTHORIZED-METER-ACCESS | Unauthorized meter access attempt |

## Security Considerations

### Access Control
- **Administrator**: Full system control, can manage operators and withdraw funds
- **Operators**: Can process consumption data and manage meter operations
- **Property Owners**: Can resolve incidents for their own meters

### Data Integrity
- All consumption data is immutably stored on the blockchain
- Tamper-proof incident records with timestamp verification
- Cryptographic security through Stacks blockchain infrastructure

### Financial Security
- Automated penalty collection prevents manual intervention
- Treasury funds are securely managed through contract logic
- All financial transactions are transparently recorded

## Monitoring & Analytics

The system provides comprehensive monitoring capabilities:

- **Real-time Consumption Tracking**: Monitor energy usage patterns
- **Anomaly Detection Reports**: Identify suspicious consumption behaviors
- **Financial Analytics**: Track penalty collections and treasury status
- **Operational Metrics**: Monitor system performance and meter status

## Support & Maintenance

### Regular Maintenance Tasks
1. Monitor system statistics for operational health
2. Review and resolve security incidents promptly
3. Maintain authorized operator list
4. Regular treasury fund management