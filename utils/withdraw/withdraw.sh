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
# Check required binaries are
# installed
# ============================
assert_binary_instaled "jq"
assert_binary_instaled "bc"

# ============================
# TODO:
# check withdraw transaction to happen before delegating
# make RPC_ADDRESS optional
# ============================

ACCOUNT_ADDRESS=`$EXECUTABLE keys show $WALLET --bech acc -a <<!
$PASSWORD
!`
[[ -z "${ACCOUNT_ADDRESS}" ]] && { echolog "Couldn't get ACCOUNT_ADDRESS, exiting."; exit 1; }
echolog "ACCOUNT_ADDRESS: $ACCOUNT_ADDRESS"

OLD_BALANCE=`$EXECUTABLE q bank balances $ACCOUNT_ADDRESS \
-o json | jq .balances[0].amount`
[[ -z "${OLD_BALANCE}" ]] && { echolog "Couldn't get OLD_BALANCE, exiting."; exit 1; }
echolog "OLD_BALANCE: $OLD_BALANCE"

VALIDATOR_ADDRESS=`$EXECUTABLE keys show $WALLET --bech val -a <<!
$PASSWORD
!`
[[ -z "${VALIDATOR_ADDRESS}" ]] && { echolog "Couldn't get VALIDATOR_ADDRESS, exiting."; exit 1; }
echolog "VALIDATOR_ADDRESS: $VALIDATOR_ADDRESS"

$EXECUTABLE tx distribution withdraw-rewards $VALIDATOR_ADDRESS --commission \
--from $WALLET --chain-id $CHAIN_ID --gas-prices $GAS_PRICES  -y <<!
$PASSWORD
!

# Hope we are lucky and 30s is enough...
sleep 30

NEW_BALANCE=`$EXECUTABLE q bank balances $ACCOUNT_ADDRESS  \
-o json | jq .balances[0].amount`
[[ -z "${NEW_BALANCE}" ]] && { echolog "Couldn't get NEW_BALANCE, exiting."; exit 1; }
echolog "NEW_BALANCE: $NEW_BALANCE"

if [[ "$OLD_BALANCE" == "$NEW_BALANCE" ]]
then
    echolog "Balance didn't change: $OLD_BALANCE, $NEW_BALANCE"
    notify_telegram "Balance didn't change: $OLD_BALANCE, $NEW_BALANCE"
    exit 1
fi

NEW_BALANCE_NUM=`$EXECUTABLE q bank balances $ACCOUNT_ADDRESS \
-o json | jq '.balances[0].amount | tonumber'`


DELEGATE_AMOUNT=$(bc <<< "$NEW_BALANCE_NUM - $GAS_BUFFER")
if [[ $DELEGATE_AMOUNT =~ - ]]
then
    echolog "Nothing delegate: $DELEGATE_AMOUNT"
    notify_telegram "Nothing delegate: $DELEGATE_AMOUNT"
    exit 1
fi

$EXECUTABLE tx staking delegate $VALIDATOR_ADDRESS $DELEGATE_AMOUNT$DENOM --from $WALLET \
--chain-id $CHAIN_ID --gas-prices $GAS_PRICES -y <<!
$PASSWORD
!

if [ $? -eq 0 ]; then
    notify_telegram "Tryed to delegate $DELEGATE_AMOUNT$DENOM"
else
    notify_telegram "Failed to delegate."
fi
