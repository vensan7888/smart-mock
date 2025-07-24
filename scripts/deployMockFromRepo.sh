#!/bin/sh

# $1: Repo URL ex: 'https://github.com/vensan7888/smart-mock.git'
# $2: Branch name ex: 'feature/Sample'
# $3: Smart-mock server url, ex: 'http://localhost:8080'
# $4: Scan full repo 'y' else ignore
# Full Command:
# 
#   To Clone Repo & 'Scan all' Yaml files to deploy contracts to mock server
#     ex: sh scripts/deployMockFromRepo.sh https://github.com/username/yourProject.git master http://localhost:8080 y
#
#   To Clone Repo & 'Scan only' Yaml files since last commir, deploy contracts to mock server
#     ex: sh scripts/deployMockFromRepo.sh https://github.com/username/yourProject.git master http://localhost:8080


REPO_URL=$1
BRANCH_NAME=$2
MOCK_SERVER=$3
SCAN_FULL_DIRECTORY=$4

CURRENT_DIRECTORY=$(pwd)
dir=$(dirname "$0")"/"
SCRIPT_PATH=$dir
COMMON_PATH="$CURRENT_DIRECTORY/$SCRIPT_PATH/common"
# 1. Fetch Repo
$(sh $COMMON_PATH/fetchRepo.sh $REPO_URL $BRANCH_NAME)
FOLDER_NAME=$(basename "$REPO_URL" .git)

FOLDER_PATH="$CURRENT_DIRECTORY/$FOLDER_NAME"

# 2. Scan repo
if [ "$SCAN_FULL_DIRECTORY" = "y" ] || [ "$SCAN_FULL_DIRECTORY" = "Y" ]; then
  YAML_FILE_PATHS=$(sh $COMMON_PATH/find_yaml_files_in_directory.sh $FOLDER_PATH)
else
  cd $FOLDER_PATH
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
      filePath=$FOLDER_PATH/$file
    fi
    echo $filePath
    # Return status of all endpoints in a given yaml file.
    status=$(sh $COMMON_PATH/yamlParser.sh $filePath $MOCK_SERVER)
    finalStatus="$finalStatus $status,"
done
finalStatus="$finalStatus]"
echo $finalStatus