# Provide the root folder path as argument or use current directory
ROOT_DIR="${1:-$(pwd)}"
#echo "Scanning Directory $ROOT_DIR"
# Find and print all .yaml and .yml files recursively
allYamlFilePaths=$(find "$ROOT_DIR" -type f \( -iname "*.yaml" -o -iname "*.yml" \))
#echo ""
#echo "All Yaml File paths:"
echo "$allYamlFilePaths"
