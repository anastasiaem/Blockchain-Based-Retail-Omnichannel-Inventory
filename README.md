# Blockchain-Based Retail Omnichannel Inventory System

A decentralized inventory management system built with Clarity smart contracts for transparent and secure retail operations across multiple channels.

## Overview

This system uses blockchain technology to create a transparent, secure, and traceable inventory management solution for retailers operating across multiple channels. By leveraging smart contracts, it ensures data integrity and provides a single source of truth for inventory levels, product information, and order fulfillment.

## Smart Contracts

### Store Verification Contract
- Validates retail locations
- Stores location details and status
- Functions for registering, verifying, and suspending stores
- Admin controls for verification

### Product Registration Contract
- Records merchandise details
- Stores product information (SKU, name, description, price, category)
- Functions for registering, updating, and deactivating products
- Status tracking for product availability

### Inventory Tracking Contract
- Monitors stock levels across locations
- Functions for adding, removing, and setting inventory quantities
- Real-time inventory visibility
- Integration with other contracts

### Allocation Contract
- Manages distribution between locations
- Functions for creating and tracking allocations
- Status tracking (pending, in-transit, completed, canceled)
- Integration with inventory tracking

### Fulfillment Contract
- Tracks order processing
- Functions for creating orders, adding items, and updating status
- Status tracking from creation to delivery
- Integration with inventory tracking

## Getting Started

### Prerequisites
- A Stacks blockchain development environment
- Clarity language knowledge

### Installation

1. Clone the repository
   \`\`\`
   git clone https://github.com/yourusername/retail-blockchain-inventory.git
   \`\`\`

2. Navigate to the project directory
   \`\`\`
   cd retail-blockchain-inventory
   \`\`\`

3. Deploy the contracts in this order:
    - Store Verification Contract
    - Product Registration Contract
    - Inventory Tracking Contract
    - Allocation Contract
    - Fulfillment Contract

### Running Tests

Execute the tests using Vitest:

\`\`\`
npm test
\`\`\`

## Usage Examples

### Register a New Store
```clarity
(contract-call? .store-verification register-store "Downtown Store" "123 Main St, City")
