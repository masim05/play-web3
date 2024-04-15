[[ -z "${FAUCET_URL}" ]] && { echolog "FAUCET_URL must be set, exiting."; exit 1; }
[[ -z "${WALLET}" ]]     && { echolog "WALLET must be set, exiting."; exit 1; }

[[ -z "${TG_TOKEN}" ]]   && echolog "TG_TOKEN not set, telegram notifications are disabled.";
[[ -z "${TG_CHAT_ID}" ]] && echolog "TG_CHAT_ID not set, telegram notifications are disabled.";

ATTEMPTS=10
RETRY_DELAY=5

echolog () {
    echo "$(date): $1";
}

notify_telegram () {
    [[ -z "${TG_TOKEN}" ]] && return;
    [[ -z "${TG_CHAT_ID}" ]] && return;

    response_code=$(curl -X POST \
     -H 'Content-Type: application/json' \
     --write-out %{http_code} --output /dev/null \
     -d '{"chat_id": "'"$TG_CHAT_ID"'", "text": "'"$1"'", "disable_notification": true}' \
     "https://api.telegram.org/bot$TG_TOKEN/sendMessage")

    [[ $response_code -ne 200 ]] && { echolog "Telegram notification failed."; }
}

for i in $(seq $ATTEMPTS); do
    
    response_code=$(curl $FAUCET_URL \
        -H 'accept: */*' \
        -H 'content-type: application/json' \
        --write-out %{http_code} --output /dev/null \
        --data-raw '{"address":"'"$WALLET"'"}');

    [[ $response_code -eq 200 ]] && { echolog "Got HTTP 200 OK."; notify_telegram "$WALLET: got 200 OK."; exit 0; }

    sleep $RETRY_DELAY;
done

echolog "No luck after $ATTEMPTS attempts.";
notify_telegram "$WALLET: no luck after $ATTEMPTS attempts.";