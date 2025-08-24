# ============================
# Helpers to be defined first
# ============================
echo_log () {
    echo "$(date): $1";
}

notify_telegram () {
    [[ -z "${TG_TOKEN}" ]] && return;
    [[ -z "${TG_CHAT_ID}" ]] && return;

    message="$1"
    response_code=$(curl -X POST \
     -H 'Content-Type: application/json' \
     --write-out %{http_code} --output /dev/null \
     -d '{"chat_id": "'"$TG_CHAT_ID"'", "text": "'"$message"'", "disable_notification": true}' \
     "https://api.telegram.org/bot$TG_TOKEN/sendMessage")

    [[ $response_code -ne 200 ]] && { echo_log "Telegram notification failed."; }
}

assert_binary_installed () {
    PATH_TO_BINARY=`which $1`
    [[ -z "${PATH_TO_BINARY}" ]] && { echo_log "$1 not found, exiting."; exit 1; };
}

# ============================
# Check required env variables
# ============================
[[ -z "${ENV_FILE}"    ]] && { echo_log "ENV_FILE must be set, exiting.";   exit 1; }
source $ENV_FILE

[[ -z "${EXECUTABLE}"  ]] && { echo_log "EXECUTABLE must be set, exiting."; exit 1; }
[[ -z "${TG_TOKEN}"    ]] && { echo_log "TG_TOKEN must be set, exiting.";   exit 1; }
[[ -z "${TG_CHAT_ID}"  ]] && { echo_log "TG_CHAT_ID must be set, exiting."; exit 1; }
[[ -z "${CHAIN_ID}"    ]] &&   echo_log "CHAIN_ID not set.";

# ============================
# Check required binaries are
# installed
# ============================
assert_binary_installed "jq"
assert_binary_installed "$EXECUTABLE"

QUERY_FLAGS="--proposal-status voting-period --output json"

VOTING_PROPOSALS=`$EXECUTABLE query gov proposals $QUERY_FLAGS | jq '.proposals | length'`

if [[ "$VOTING_PROPOSALS" -ne 0 ]]; then
    notify_telegram "$CHAIN_ID:\n$VOTING_PROPOSALS active proposal(s) found."
    echo_log "$CHAIN_ID:\n$VOTING_PROPOSALS active proposal(s) found."
    exit 0
fi

echo_log "No proposals in voting period found, exiting."
exit 0
