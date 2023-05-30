#unlock
#!/bin/bash

assets=/app/ppp4/code/Week03/assets
keypath=/app/ppp4/keys
name="$1"
collateral="$2"
txin="$3"
signer_hash="$4"
slot="$5"

pp="$assets/protocol-parameters.json"
body="$assets/collect-vest.txbody"
tx="$assets/collect-vest.tx"
RefScriptTxHashRefScriptTxIndex="205bacb5c0384c32dce8de6b75c1f531a5a10aa84f055276c486a51787bf5f54#0"

# Query the protocol parameters \

cardano-cli query protocol-parameters \
    --testnet-magic 2 \
    --out-file "$pp"

# Build the transaction
cardano-cli transaction build \
    --babbage-era \
    --testnet-magic 2 \
    --tx-in "$txin" \
    --spending-tx-in-reference $RefScriptTxHashRefScriptTxIndex \
    --spending-plutus-script-v2 \
    --spending-reference-tx-in-inline-datum-present \
    --spending-reference-tx-in-redeemer-file "$assets/datum.json" \
    --tx-in-collateral "$collateral" \
    --change-address "$(cat "$keypath/$name.addr")" \
    --protocol-params-file "$pp" \
    --required-signer-hash $signer_hash \
    --invalid-before $slot \
    --out-file "$body"

# Unlock the 5 ADA from the contract address and send it to your wallet address

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
