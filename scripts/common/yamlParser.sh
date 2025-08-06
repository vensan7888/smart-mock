
FILE=$1
HOST_URL=$2

paths=$(yq eval '.paths | keys | .[]' $FILE)

# Function to return default values based on type
get_default_value() {
  case "$1" in
    string) echo '"string"' ;;
    boolean) echo 'false' ;;
    integer) echo '0' ;;
    number) echo '1.0001' ;;
    *) echo 'null' ;;
  esac
}
# Function to return example values based on type
get_example_format_value() {
  case "$1" in
    string) printf '"%s"\n' "$2" ;;
    boolean) echo $2 ;;
    integer) echo $2 ;;
    number) echo $2 ;;
    *) echo 'null' ;;
  esac
}
# $1 base query, $2 object type array/object
generateJson() {
    if [ "$2" = "array" ]; then
        jsonString="[{"
        closingCharecter="}]"
    else
        jsonString="{"
        closingCharecter="}"
    fi
    first=1
    propertyBaseQuery=$1

    properties=$(yq eval "$propertyBaseQuery.properties | keys | .[]" $FILE)
    parameterObject=$(yq "$propertyBaseQuery.properties" $FILE)
    for property in $properties; do
        key=$property
        type=$(yq "$propertyBaseQuery.properties.$property.type" $FILE)
        # Default value while configuring contract mock.
        example=$(yq "$propertyBaseQuery.properties.$property.example" $FILE)
        value=""
        if [ $type = "object" ] || [ $type = "array" ]; then
            newQuery="$propertyBaseQuery.properties.$property"
            nestedObject=$(generateJson $newQuery $type)
            value=$nestedObject
        else
            value=$(get_default_value $type)
            if [ -n "$example" ]; then
                value=$(get_example_format_value $type $example)
            fi
        fi
        if [ $first -eq 1 ]; then
            jsonString="$jsonString\"$key\": $value"
            first=0
        else
            jsonString="$jsonString, \"$key\": $value"
        fi
    done
    jsonString="$jsonString$closingCharecter"
    echo $jsonString
}

generateRequestStructure() {
    type=$2
    # Remove the leading "#/" part
    cleaned=$(echo "$1" | sed 's|^#\/||')

    # Split by '/'
    OLD_IFS="$IFS"
    IFS='/'
    set -- $cleaned
    IFS="$OLD_IFS"

    # Optional: Use these variables later
    components=$1
    schemas=$2
    name=$3
   
    propertyBaseQuery=".$components.""$schemas.$name"
    json=$(generateJson $propertyBaseQuery $type)
    echo $json
}

deployMock() {
    url="$HOST_URL/deployContract"
    response="$3"
    json=$(printf '{"endpoint": "%s", "request": %s, "response": %s}' "$1" "$2" "$response")
    hostResponse=$(curl -s -w "\n%{http_code}" \
                        -X POST "$url" \
                        -H "Content-Type: application/json" \
                        -d "$json")
    # Separate body and status
    response_body=$(echo "$hostResponse" | sed '$d')
    response_status=$(echo "$hostResponse" | tail -n1)
    # Check the status code
    if [ "$response_status" -eq 200 ]; then
        echo $response_body
    else
        echo "<$response_status> <$json> <$response_body>"
    fi
}

for path in $paths; do
  #echo "📌 Path: $path"

  # Step 3: Get HTTP methods under this path
    methods=$(yq eval ".paths.\"$path\" | keys | .[]" $FILE)
    finalStatus="["    
  for method in $methods; do
    if [ "$method" != "post" ]; then
        #echo "Skipping $method"
        continue
    fi
    # Step 4: Print method and summary
    summary=$(yq eval ".paths.\"$path\".$method.summary" $FILE)
    #echo "  - Method: $method"
    #echo "    Summary: $summary"

    contentType="application/json"
    structurePathRef="\$ref"
    requestStructurePath=$(yq eval ".paths.\"$path\".$method.requestBody.content.$contentType.schema.$structurePathRef" $FILE)

    responseType=$(yq eval ".paths.\"$path\".$method.responses.200.content.$contentType.schema.type" $FILE)
    if [ "$responseType" = "array" ]; then
        responseStructurePath=$(yq eval ".paths.\"$path\".$method.responses.200.content.$contentType.schema.items.$structurePathRef" $FILE)
    else
        responseStructurePath=$(yq eval ".paths.\"$path\".$method.responses.200.content.$contentType.schema.$structurePathRef" $FILE)
    fi

    reqStructure=$(generateRequestStructure "$requestStructurePath" "object")
    #echo "reqStructure == $reqStructure"
    cleanedPath="${path#/}"
    responseStructure=$(generateRequestStructure $responseStructurePath $responseType)

    # In case if no response is configured for 200 http status.
    if [ "$responseStructure" = "{}" ]; then
        # *** ERROR ***
        echo "<HttpStatus '200' is missing in responses of $FILE, As of now smart-mock supports only HttpStatus = '200' & HttpMethod = 'POST'>"
        exit 1
    fi

    deployedResponse=$(deployMock $cleanedPath "$reqStructure" "$responseStructure")

    read -r hostStatusCode _ <<< "$deployedResponse"
    if [ -z "$deployedResponse" ] || [ $hostStatusCode = "<400>" ]; then
        # *** ERROR ***
        echo $deployedResponse #="Failed to deploy!!!"
        exit 1
    fi

    if ! echo "$deployedResponse" | grep -q "requestStructure"; then
        # *** ERROR *** In case if smart-mock responds with error then fail the jenkins job!
        echo $deployedResponse
        exit 1
    fi

    finalStatus="{"$path" : "$deployedResponse"}"
  done
  finalStatus="$finalStatus]"
  echo $finalStatus
done
