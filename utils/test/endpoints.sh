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

test "https://rpc.galactica.crptmax.com/"
test "https://api.galactica.crptmax.com/"

test "https://rpc.0g.crptmax.com/"
test "https://api.0g.crptmax.com/" 501

#test "https://rpc.band.crptmax.com/"
#test "https://api.band.crptmax.com/"