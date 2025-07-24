#!/bin/sh

# $1: Smart-mock server url, ex: 'http://localhost:8080'
# Full Command:
# 
#   To Clone Repo & Scan all Yaml files to deploy contracts to mock server
#     ex: sh scripts/jenkinsDeployMock.sh http://localhost:8080 y
#
#   To Clone Repo & 'Scan only' Yaml files since last commit, deploy contracts to mock server
#     ex: sh scripts/jenkinsDeployMock.sh http://localhost:8080

MOCK_SERVER=$1
SCAN_FULL_DIRECTORY=$2

CURRENT_DIRECTORY=$(pwd)
dir=$(dirname "$0")"/"
SCRIPT_PATH=$dir
COMMON_PATH="$CURRENT_DIRECTORY/$SCRIPT_PATH/common"
echo "Path : $0 $dir"

# 2. Scan repo
if [ "$SCAN_FULL_DIRECTORY" = "y" ] || [ "$SCAN_FULL_DIRECTORY" = "Y" ]; then
  YAML_FILE_PATHS=$(sh $COMMON_PATH/find_yaml_files_in_directory.sh $CURRENT_DIRECTORY)
else
  # Get latest commit hash
  LATEST_COMMIT=$(git rev-parse HEAD)
  # Collect added or modified YAML files in an array
  YAML_FILE_PATHS=($(git diff-tree --no-commit-id --name-status -r "$LATEST_COMMIT" \
  | awk '$1 == "A" || $1 == "M" {print $2}' \
  | grep -E '\.ya?ml$'))
  cd ..
fi

finalStatus="["
for file in "${YAML_FILE_PATHS[@]}"; do
  if [ "$SCAN_FULL_DIRECTORY" = "y" ] || [ "$SCAN_FULL_DIRECTORY" = "Y" ]; then
    filePath=$file
  else
    filePath="$CURRENT_DIRECTORY/$file"
  fi
  # Return status of all endpoints in a given yaml file.
  status=$(sh "$COMMON_PATH"/yamlParser.sh $filePath $MOCK_SERVER)
  finalStatus="$finalStatus $status,"
done
finalStatus="$finalStatus]"
echo $finalStatus


