echolog () {
    echo "$(echo $WALLET | head -c 6)/$(date): $1";
}

notify_telegram () {
    [[ -z "${TG_TOKEN}" ]] && return;
    [[ -z "${TG_CHAT_ID}" ]] && return;

    message="$(echo $WALLET | head -c 6)@$(hostname): $1"
    response_code=$(curl -X POST \
     -H 'Content-Type: application/json' \
     --write-out %{http_code} --output /dev/null \
     -d '{"chat_id": "'"$TG_CHAT_ID"'", "text": "'"$message"'", "disable_notification": true}' \
     "https://api.telegram.org/bot$TG_TOKEN/sendMessage")

    [[ $response_code -ne 200 ]] && { echolog "Telegram notification failed."; }
}

[[ -z "${ENV_FILE}" ]] && { echolog "ENV_FILE must be set, exiting."; exit 1; }
source $ENV_FILE

[[ -z "${FAUCET_URL}" ]] && { echolog "FAUCET_URL must be set, exiting."; exit 1; }
[[ -z "${WALLET}" ]]     && { echolog "WALLET must be set, exiting."; exit 1; }

[[ -z "${TG_TOKEN}" ]]   && echolog "TG_TOKEN not set, telegram notifications are disabled.";
[[ -z "${TG_CHAT_ID}" ]] && echolog "TG_CHAT_ID not set, telegram notifications are disabled.";

[[ -z "${PROXY}" ]]      && echolog "PROXY not set, exposing IP.";

ATTEMPTS=10
RETRY_DELAY=5

for i in $(seq $ATTEMPTS); do
    
    response_code=$(curl $FAUCET_URL \
        -H 'accept: */*' \
        -H 'content-type: application/json' \
        --write-out %{http_code} --output /dev/null \
        $([[ -z "${PROXY}" ]] || echo "-x $PROXY") \
        --data-raw '{"address":"'"$WALLET"'"}');

    [[ $response_code -eq 200 ]] && { echolog "Got HTTP 200 OK."; notify_telegram "Got HTTP 200 OK."; exit 0; }

    sleep $RETRY_DELAY;
done

echolog "No luck after $ATTEMPTS attempts.";
notify_telegram "No luck after $ATTEMPTS attempts.";