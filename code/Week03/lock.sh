#!/bin/bash

assets=/app/ppp4/code/Week03/assets
keypath=/app/ppp4/keys
name="$1"
txin="$2"
sm="$3"
body="$assets/build.txbody"
tx="$assets/sign.tx"

# Build vest address 
cardano-cli address build \
    --payment-script-file "$assets/$sm.plutus" \
    --testnet-magic 2 \
    --out-file "$assets/$sm.addr"

# Build the transaction
cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 2 \
    --tx-in "$txin" \
    --tx-out "$(cat "$assets/$sm.addr") + 12300135 lovelace" \
    --tx-out-inline-datum-file "$assets/datum.json" \
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

tid=$(cardano-cli transaction txid --tx-file "$tx")
echo "transaction id: $tid"
echo "Cardanoscan: https://preview.cardanoscan.io/transaction/$tid"
