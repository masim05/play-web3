test () {
    URL=$1
    EXPECTED_RESPONSE_CODE=$2
    [[ -z "${EXPECTED_RESPONSE_CODE}" ]] && EXPECTED_RESPONSE_CODE=200;
    echo -n "$URL:    "
    RESPONSE_CODE=`curl -s -o /dev/null -w "%{http_code}"  $URL`
    if [[ $RESPONSE_CODE -ne $EXPECTED_RESPONSE_CODE ]]
    then
        { echo "Failed: $RESPONSE_CODE"; }
    else
        { echo "Ok."; }
    fi
}

test "https://rpc.alignedlayer.crptmax.com/"
test "https://api.alignedlayer.crptmax.com/"
test "https://rpc.alignedlayer-t.crptmax.com/"
test "https://api.alignedlayer-t.crptmax.com/"
wscat --connect wss://rpc.alignedlayer-t.crptmax.com/websocket \
-x '{ "jsonrpc": "2.0", "method": "status", "id": 1 }' > /dev/null

test "https://rpc.galactica.crptmax.com/"
test "https://api.galactica.crptmax.com/"
test "https://rpc.galactica-t.crptmax.com/"
test "https://api.galactica-t.crptmax.com/"
wscat --connect wss://rpc.galactica-t.crptmax.com/websocket \
-x '{ "jsonrpc": "2.0", "method": "status", "id": 1 }' > /dev/null

test "https://rpc.0g.crptmax.com/"
test "https://api.0g.crptmax.com/" 501
test "https://rpc.0g-t.crptmax.com/"
test "https://api.0g-t.crptmax.com/" 501
wscat --connect wss://rpc.0g-t.crptmax.com/websocket \
-x '{ "jsonrpc": "2.0", "method": "status", "id": 1 }' > /dev/null

test "https://rpc.band.crptmax.com/"
test "https://api.band.crptmax.com/" 501
wscat --connect wss://rpc.band.crptmax.com/websocket \
-x '{ "jsonrpc": "2.0", "method": "status", "id": 1 }' > /dev/null

grpcurl grpc.band.crptmax.com:26443 list > /dev/null;
grpcurl grpc.galactica-t.crptmax.com:22443 list > /dev/null;
grpcurl grpc.alignedlayer-t.crptmax.com:23443 list > /dev/null;
grpcurl grpc.0g-t.crptmax.com:19443 list > /dev/null;
