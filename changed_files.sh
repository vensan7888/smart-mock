#!/bin/sh

# Check if repo URL is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <git-repo-url>" #[local-folder-name]"
  exit 1
fi

REPO_URL="$1"
#FOLDER_NAME="$2"

# If local folder name not given, extract it from repo URL
if [ -z "$FOLDER_NAME" ]; then
  FOLDER_NAME=$(basename "$REPO_URL" .git)
fi

# Clone or fetch the repo
if [ ! -d "$FOLDER_NAME/.git" ]; then
  #echo "📥 Cloning repository..."
  git clone "$REPO_URL" "$FOLDER_NAME"
else
  #echo "🔄 Fetching latest changes in $FOLDER_NAME..."
  cd "$FOLDER_NAME" || exit 1
  git fetch origin
  cd ..
fi

# Navigate to repo folder
cd "$FOLDER_NAME" || exit 1

# Checkout and update latest master branch
git checkout feature/yamlTest >/dev/null 2>&1
git pull origin feature/yamlTest >/dev/null 2>&1

# Get latest commit hash
LATEST_COMMIT=$(git rev-parse HEAD)
# Print only added or modified files
#echo "🔍 Added or modified files in latest commit ($LATEST_COMMIT):"
#git diff-tree --no-commit-id --name-status -r "$LATEST_COMMIT" | awk '$1 == "A" || $1 == "M" {print $2}'

# Collect added or modified YAML files in an array
YAML_FILES=($(git diff-tree --no-commit-id --name-status -r "$LATEST_COMMIT" \
  | awk '$1 == "A" || $1 == "M" {print $2}' \
  | grep -E '\.ya?ml$'))

echo $YAML_FILES

# Print array
#echo "📂 YAML files changed in latest commit ($LATEST_COMMIT):"
#for file in "${YAML_FILES[@]}"; do
#  echo "- $file"
#done