#! /bin/bash
REST_API_ID=7zgk5akmk8
RESOURCES=$(aws apigateway get-resources --rest-api-id $REST_API_ID)
LIST_RESOURCE_ID=$(echo $RESOURCES | jq '."items"')
echo $LIST_RESOURCE_ID > "api-gateway.json"
jq -c '.[]' api-gateway.json | while read resource;
do
    RESOURCE_ID=$(echo $resource | jq -r '.id')
    RESOURCE_PATH=$(echo $resource | jq -r '.path')
    echo "Resource: "$RESOURCE_PATH" - "$RESOURCE_ID
    HAS_EXIST_RESOURCE=$(cat $resource | jq 'has("resourceMethods")')
    echo $HAS_EXIST_RESOURCE
    if [[ ! $HAS_EXIST_RESOURCE ]]; then
        echo "Resource: $RESOURCE_PATH has not any methods"
        continue
    fi
    RESOURCE_METHOD=$(echo $resource  | jq '.resourceMethods | keys' | jq -r '.[]')
    for method in $RESOURCE_METHOD
    do
        # trim string
        method_format=`echo $method | sed 's/ *$//g'`
        if [[ "$method_format" == 'OPTIONS' ]]; then
            continue
        fi
        echo "METHOD: $method_format - $RESOURCE_PATH - $RESOURCE_ID >>>"
        RESOURCE_DETAIL=$(aws apigateway get-integration --rest-api-id $REST_API_ID --resource-id $RESOURCE_ID --http-method $method_format)
        INTEGRATION_TYPE=$(echo $RESOURCE_DETAIL | jq -r '.type')
        if [[ "$INTEGRATION_TYPE" == 'MOCK' ]]; then
            echo "MOCK API"
            continue
        fi
        LAMBDA_URI=$(echo $RESOURCE_DETAIL | jq '.uri')
        echo $LAMBDA_URI
        
    done
done
