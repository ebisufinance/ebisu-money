#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check if RPC_URL and PRIVATE_KEY are set
if [ -z "$RPC_URL" ] || [ -z "$PRIVATE_KEY" ]; then
  echo "Error: RPC_URL or PRIVATE_KEY is not set in the .env file."
  exit 1
fi

# # Print the loaded environment variables for debugging
# echo "Using RPC_URL: $RPC_URL"
# echo "Using PRIVATE_KEY: $PRIVATE_KEY"

#forge script src/scripts/DeployEbisu_forked.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --slow

# deploy testnet script
forge script src/scripts/DeployEbisu_Testnet.s.sol:DeployEbisuTestnet --rpc-url $RPC_URL --private-key $PRIVATE_KEY --slow --broadcast