#Reference Plutus V2

#!/bin/bash

assets=/app/ppp4/code/Week03/assets
keypath=/app/ppp4/keys
name="$1"
txin="$2"
body="$assets/vest.txbody"
tx="$assets/vest.tx"

# Build Tx wih a plutus reference script attached to it
cardano-cli address build \
    --payment-script-file "$assets/vest.plutus" \
    --testnet-magic 2 \
    --out-file "$assets/vest.addr"

# Build the transaction
cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 2 \
    --tx-in "$txin" \
    --tx-out "$(cat "$assets/vest.addr") + 15345689 lovelace" \
    --tx-out-inline-datum-file "$assets/datum.json" \
    --tx-out-reference-script-file $assets/vest.plutus \
    --change-address "$(cat "$keypath/$name.addr")" \
    --out-file "$body"
    
# Sign the transaction
cardano-cli transaction sign \
    --tx-body-file "$body" \
    --signing-key-file "$keypath/$name.skey" \
    --testnet-magic 2 \
    --out-file "$tx"

# Submit the transaction
cardano-cli transaction submit \
    --testnet-magic 2 \
    --tx-file "$tx"
