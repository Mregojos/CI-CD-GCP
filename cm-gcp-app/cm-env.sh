# Environemnt Variable
export ZONE="us-west1-a"
echo "Username?"
read -s USERNAME # This VM Name

# Environment Variable for App
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
export FIREWALL_RULES_NAME="$APP_NAME-ports"
export VPC_NAME="$APP_NAME-vpc"
export TAGS="db"
export BUCKET_NAME="$APP_NAME-startup-script"
export STARTUP_SCRIPT_BUCKET_SA="$APP_NAME-bucket-sa"
export STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE="cicdOssGCPBucketCustomRole.$VERSION"

echo "#------------Done-------------#"