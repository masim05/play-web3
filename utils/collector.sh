# ============================
# Helpers to be defined first
# ============================
echolog () {
    echo "$(echo $EXECUTABLE | head -c 4)/$(date): $1";
}

notify_telegram () {
    [[ -z "${TG_TOKEN}" ]] && return;
    [[ -z "${TG_CHAT_ID}" ]] && return;

    message="$(echo $EXECUTABLE | head -c 4): $1"
    response_code=$(curl -X POST \
     -H 'Content-Type: application/json' \
     --write-out %{http_code} --output /dev/null \
     -d '{"chat_id": "'"$TG_CHAT_ID"'", "text": "'"$message"'", "disable_notification": true}' \
     "https://api.telegram.org/bot$TG_TOKEN/sendMessage")

    [[ $response_code -ne 200 ]] && { echolog "Telegram notification failed."; }
}

assert_binary_instaled () {
    PATH_TO_BINARY=`which $1`
    [[ -z "${PATH_TO_BINARY}" ]] && { echolog "$1 not found, exiting."; exit 1; };
}

# ============================
# Check required binaries are
# installed
# ============================
assert_binary_instaled "jq"
assert_binary_instaled "bc"

# ============================
# Check required env variables
# ============================
[[ -z "${ENV_FILE}" ]]    && { echolog "ENV_FILE must be set, exiting."; exit 1; }
source $ENV_FILE

[[ -z "${EXECUTABLE}" ]]  && { echolog "EXECUTABLE must be set, exiting."; exit 1; }
[[ -z "${CHAIN_ID}" ]]    && { echolog "CHAIN_ID must be set, exiting."; exit 1; }
[[ -z "${WALLET}" ]]      && { echolog "WALLET must be set, exiting."; exit 1; }
[[ -z "${PASSWORD}" ]]    && { echolog "PASSWORD must be set, exiting."; exit 1; }
[[ -z "${GAS_PRICES}" ]]  && { echolog "GAS_PRICES must be set, exiting."; exit 1; }
[[ -z "${DENOM}" ]]       && { echolog "DENOM must be set, exiting."; exit 1; }
[[ -z "${GAS_BUFFER}" ]]  && { echolog "GAS_BUFFER must be set, exiting."; exit 1; }

[[ -z "${TG_TOKEN}" ]]    && echolog "TG_TOKEN not set, telegram notifications are disabled.";
[[ -z "${TG_CHAT_ID}" ]]  && echolog "TG_CHAT_ID not set, telegram notifications are disabled.";

# ============================
# Main logic
# ============================
KEYS=`$EXECUTABLE keys list --output json <<!
$PASSWORD
!`

COLLECTOR_ADDRESS=`$EXECUTABLE keys show $WALLET -a <<!
$PASSWORD
!`
[[ -z "${COLLECTOR_ADDRESS}" ]] && { echolog "Couldn't get COLLECTOR_ADDRESS, exiting."; exit 1; }

TOTAL_SEND=0

echo $KEYS | jq -r '.[].address' | while read -r FROM_ADDRESS
do
    #echo $FROM_ADDRESS, $COLLECTOR_ADDRESS

    if [[ "$FROM_ADDRESS" == "$COLLECTOR_ADDRESS" ]]
    then
        echolog "Skipping myself"
        continue 
    fi

    BALANCE=`$EXECUTABLE q bank balances $FROM_ADDRESS \
    -o json | jq -r '.balances[0].amount'`
    [[ -z "${BALANCE}" ]] && { echolog "Couldn't get BALANCE, exiting."; exit 1; }

    SEND_AMOUNT=$(bc <<< "$BALANCE - $GAS_BUFFER")
    if [[ $SEND_AMOUNT =~ - ]]
    then
        echolog "Nothing delegate: $DELEGATE_AMOUNT"
        continue
    fi

    $EXECUTABLE tx bank send $FROM_ADDRESS $COLLECTOR_ADDRESS $SEND_AMOUNT$DENOM --chain-id $CHAIN_ID \
    --gas-prices $GAS_PRICES -y <<!
$PASSWORD
!

    if [ $? -eq 0 ]; then
        TOTAL_SEND=$(bc <<< "$TOTAL_SEND + $SEND_AMOUNT")
    else
        echolog "Send $SEND_AMOUNT$DENOM from $FROM_ADDRESS failed."
    fi

    echo "TOTAL_SEND: $TOTAL_SEND"
done

echolog "Tryed to send."
notify_telegram "Tryed to send."
