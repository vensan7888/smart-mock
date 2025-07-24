#!/bin/sh

# Check if repo URL is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <git-repo-url>"
  exit 1
fi

REPO_URL="$1"
BRANCH_NAME="$2"

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
git checkout $BRANCH_NAME >/dev/null 2>&1
git pull origin $BRANCH_NAME >/dev/null 2>&1