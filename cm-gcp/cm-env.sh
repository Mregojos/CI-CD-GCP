# Environemnt Variable
export ZONE="us-west1-a"
echo "Username?"
read -s USERNAME # This VM Name

# Environment Variable for App
export VERSION="ix"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
export BUCKET_NAME="$APP_NAME-startup-script"
export FIREWALL_RULES_NAME="$APP_NAME-ports"
export VPC_NAME="$APP_NAME-vpc"
export TAGS="db"
export STARTUP_SCRIPT_BUCKET_SA="$APP_NAME-bucket-sa"

echo "#------------Done-------------#"