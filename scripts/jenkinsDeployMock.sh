#!/bin/sh

# $1: Smart-mock server url, ex: 'http://localhost:8080'
# Full Command:
# 
#   To Clone Repo & Scan all Yaml files to deploy contracts to mock server.
#     ex: sh scripts/jenkinsDeployMock.sh http://localhost:8080 y
#
#   To Clone Repo & Scan Only Yaml files changed in latest commit to deploy contracts to mock server.
#     ex: sh scripts/jenkinsDeployMock.sh http://localhost:8080

MOCK_SERVER=$1
SCAN_FULL_DIRECTORY=$2
MOCK_SYSTEM="SMART-MOCK"

CURRENT_DIRECTORY=$(pwd)
dir=$(dirname "$0")"/"
SCRIPT_PATH="$CURRENT_DIRECTORY/$dir"
COMMON_PATH="$SCRIPT_PATH""common"

# 2. Scan repo
if [ "$SCAN_FULL_DIRECTORY" = "y" ] || [ "$SCAN_FULL_DIRECTORY" = "Y" ]; then
  YAML_FILE_PATHS=$(sh $COMMON_PATH/find_yaml_files_in_directory.sh $CURRENT_DIRECTORY)
  echo ""
  echo "All YAML Files in repo:"
  echo ""
  if [ -n "$YAML_FILE_PATHS" ]; then
      echo "$YAML_FILE_PATHS"
  else
    echo "****** No YAML file found in Repo to update '$MOCK_SYSTEM' ******"
  fi
  echo ""
else
  # Get latest commit hash
  LATEST_COMMIT=$(git rev-parse HEAD)
  # Collect added or modified YAML files in an array
  YAML_FILE_PATHS=$(git diff-tree --no-commit-id --name-status -r "$LATEST_COMMIT" \
  | awk '$1 == "A" || $1 == "M" {print $2}' \
  | grep -E '\.ya?ml$')
  cd ..
  echo ""
  echo "All YAML Files in latest commit:"
  echo ""
  if [ -n "$YAML_FILE_PATHS" ]; then
    echo "$YAML_FILE_PATHS"
  else
    echo "****** No YAML file found in latest commit to update '$MOCK_SYSTEM' ******"
  fi
  echo ""
fi

counter=1
while IFS= read -r path; do
  file=$path;
  if [ "$SCAN_FULL_DIRECTORY" = "y" ] || [ "$SCAN_FULL_DIRECTORY" = "Y" ]; then
    filePath=$file
  else
    filePath="$CURRENT_DIRECTORY/$file"
  fi

  if [ -f "$filePath" ]; then
    echo ""
    echo "Configuring '$MOCK_SYSTEM' for $filePath"
    echo ""
    # Return status of all endpoints in a given yaml file.
    status=$(sh "$COMMON_PATH"/yamlParser.sh $filePath $MOCK_SERVER)
    
    read -r hostStatusCode _ <<< "$status"
    if [ -z "$status" ] || [ "$hostStatusCode" = "<400>" ]; then
      matches=$(echo "$status" | grep -o '<[^>]*>')
      # *** ERROR ***
      # Extract JSON and host response fail Jenkins job incase of status code '400'
      response_status=$(echo "$matches" | sed -n '1p' | sed 's/[<>]//g')
      request_data=$(echo "$matches" | sed -n '2p' | sed 's/[<>]//g')
      response_data=$(echo "$matches" | sed -n '3p' | sed 's/[<>]//g')
      echo ""
      echo "🔹 Tried to deploy: $request_data"
      echo ""
      echo "🔹 Received: $response_data"
      echo ""
      echo "Failed to deploy!!!"
      echo ""
      exit 1
    fi

    echo ""
    echo "Status: $status"
    echo ""

    if ! echo "$status" | grep -q "requestStructure"; then
      # *** ERROR ***
      # In case if smart-mock responds with error then fail the jenkins job!
      echo "Failed to deploy!!!"
      echo ""
      exit 1
    fi

  fi
  counter=$((counter + 1))
done <<EOF
$YAML_FILE_PATHS
EOF



