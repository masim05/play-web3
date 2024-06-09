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
test_http "https://rpc.alignedlayer.crptmax.com/"
test_http "https://api.alignedlayer.crptmax.com/"
test_http "https://rpc.alignedlayer-t.crptmax.com/"
test_http "https://api.alignedlayer-t.crptmax.com/"

test_http "https://rpc.galactica.crptmax.com/"
test_http "https://api.galactica.crptmax.com/"
test_http "https://rpc.galactica-t.crptmax.com/"
test_http "https://api.galactica-t.crptmax.com/"

test_http "https://rpc.0g.crptmax.com/"
test_http "https://api.0g.crptmax.com/" 501
test_http "https://rpc.0g-t.crptmax.com/"
test_http "https://api.0g-t.crptmax.com/" 501

test_http "https://rpc.band.crptmax.com/"
test_http "https://api.band.crptmax.com/" 501

printf "\nWS endpoints\n"
test_ws "rpc.band.crptmax.com"
test_ws "rpc.alignedlayer-t.crptmax.com"
test_ws "rpc.galactica-t.crptmax.com"
test_ws "rpc.0g-t.crptmax.com"

printf "\ngRPC endpoints\n"
test_grpc "grpc.band.crptmax.com:26443"
test_grpc "grpc.galactica-t.crptmax.com:22443"
test_grpc "grpc.alignedlayer-t.crptmax.com:23443"
test_grpc "grpc.0g-t.crptmax.com:21443"

