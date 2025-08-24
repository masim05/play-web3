test_http () {
    URL=$1
    EXPECTED_RESPONSE_CODE=$2
    [[ -z "${EXPECTED_RESPONSE_CODE}" ]] && EXPECTED_RESPONSE_CODE=200;
    echo -n "$URL:    "
    RESPONSE_CODE=`curl -s -o /dev/null -w "%{http_code}"  $URL`
    if [[ $RESPONSE_CODE -ne $EXPECTED_RESPONSE_CODE ]]
    then
        { printf "Failed: $RESPONSE_CODE\n"; }
    else
        { printf "Ok.\n"; }
    fi
}

test_ws () {
    URL=$1
    printf "$URL\n"
    wscat --connect wss://$URL/websocket \
    -x '{ "jsonrpc": "2.0", "method": "status", "id": 1 }' > /dev/null
}

test_grpc () {
    URL=$1
    printf "$URL\n"
    grpcurl $URL list > /dev/null;
}

printf "HTTP endpoints\n"

test_http "https://rpc.arkeo.crptmax.com/"
test_http "https://rpc.arkeo-t.crptmax.com/"

printf "\nWS endpoints\n"
test_ws "rpc.arkeo.crptmax.com"
test_ws "rpc.arkeo-t.crptmax.com"

printf "\ngRPC endpoints\n"
test_grpc "grpc.arkeo.crptmax.com:22443"
test_grpc "grpc.arkeo-t.crptmax.com:21443"

