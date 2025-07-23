# Ex Sh command to run this file:
# sh checkDeployContractsInMock.sh https://repoUrl.com/repo.git https://your-serverUrl-with-smart-mock
# Accept  repo url '$1', smart mock server '$2' to deploy mock services
# Create a local smart-mock cache whether it ran previously or not, or accept one paramter to force update all files in repo.
REPO_URL=$1
SMART_MOCK_SERVER=$2

# 1. Fetch recently changed yaml file paths from master
YAML_FILE_PATHS=$(sh changed_files.sh $REPO_URL)
FOLDER_NAME=$(basename "$REPO_URL" .git)
# Get latest commit hash
#LATEST_COMMIT=$(git rev-parse HEAD)

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
# 2. Deploy all yaml changes to mock server
# $1 filepath, $2 base query, $3 object type array/object
echo "📂 YAML files changed in latest commit"
finalStatus="["
for file in "${YAML_FILE_PATHS[@]}"; do
    filePath=$FOLDER_NAME/$file
    echo $filePath
    # Return status of all endpoints in a given yaml file.
    status=$(sh yamlParser.sh $filePath $SMART_MOCK_SERVER)
    finalStatus="$finalStatus $status,"
done
finalStatus="$finalStatus]"
echo $finalStatus

