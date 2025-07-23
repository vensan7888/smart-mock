
FILE=$1
HOST_URL=$2
#echo $FILE

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
    #echo "Properties : $properties"
    #echo "Property Object : $parameterObject"
    for property in $properties; do
        key=$property
        type=$(yq "$propertyBaseQuery.properties.$property.type" $FILE)
        #echo "DataType $key And $type End.."
        value=""
        if [ $type = "object" ] || [ $type = "array" ]; then
            newQuery="$propertyBaseQuery.properties.$property"
            nestedObject=$(generateJson $newQuery $type)
            value=$nestedObject
        else
            value=$(get_default_value $type)
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
   
#    jsonString="{"
#    first=1
    propertyBaseQuery=".$components.""$schemas.$name"
    json=$(generateJson $propertyBaseQuery $type)
    echo $json
}

deployMock() {
    url="$HOST_URL/deployContract"
    response="$3"
    
    #echo ""    
    #echo "Start:::"
    json=$(printf '{"endpoint": "%s", "request": %s, "response": %s}' "$1" "$2" "$response")
    hostResponse=$(curl -X POST "$url" \
                        -H "Content-Type: application/json" \
                        -d "$json") 
    #echo ""
    #echo "End:::"
    #echo ""
    echo $hostResponse
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
    cleanedPath="${path#/}"
    #echo "Clean path:: $cleanedPath"
    #echo "Request Structure of $path:"
    #echo "$reqStructure"
    #echo ""
    #echo "Response Type:: $responseType $responseStructurePath"
    #echo "Response Structure:"
    responseStructure=$(generateRequestStructure $responseStructurePath $responseType)
    #echo "$responseStructure"
    #echo ""
    deployedResponse=$(deployMock $cleanedPath "$reqStructure" "$responseStructure")
    #echo $deployedResponse
    if [ -z "$deployedResponse" ]; then
        deployedResponse="Failed to deploy!!!"
    fi
    finalStatus="{"$path" : "$deployedResponse"}"
  done
  finalStatus="$finalStatus]"
  echo $finalStatus
done
