
[[ -z "${FAUCET_URL}" ]] && { echo "$(date): FAUCET_URL must be set, exiting."; exit 1; }

[[ -z "${WALLET}" ]] && { echo "$(date): WALLET must be set, exiting."; exit 1; }

ATTEMPTS=10
RETRY_DELAY=5

for i in $(seq $ATTEMPTS); do
    
    response_code=$(curl $FAUCET_URL \
        -H 'accept: */*' \
        -H 'content-type: application/json' \
        --write-out %{http_code} --output /dev/null \
        --data-raw '{"address":"'"$WALLET"'"}');

    [[ $response_code -eq 200 ]] && { echo "$(date): Got HTTP 200 OK."; exit 0; }

    sleep $RETRY_DELAY;
done

echo "$(date): No luck after $ATTEMPTS attempts."