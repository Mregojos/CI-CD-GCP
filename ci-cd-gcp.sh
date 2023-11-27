# Environment Variables
#---------Application Name Environment Variables----------#
VERSION="i"
APP_NAME="ci-cd-gcp-$VERSION"

#---------Project Environment Variables---------#
PROJECT_NAME="$(gcloud config get project)"

#----------Database Instance Environment Variables----------#
VPC_NAME="$APP_NAME-vpc"
SUBNET_NAME="$APP_NAME-subnet"
RANGE_A='10.100.0.0/20'
RANGE_B='10.200.0.0/20'
DB_INSTANCE_NAME="$APP_NAME-db"
MACHINE_TYPE="e2-micro"
REGION="us-west1"
ZONE="us-west1-a"
BOOT_DISK_SIZE="30"
TAGS="db"
FIREWALL_RULES_NAME="$APP_NAME-ports"
STATIC_IP_ADDRESS_NAME="$APP_NAME-db-static-ip-address"
BUCKET_NAME="$APP_NAME-startup-script"
STARTUP_SCRIPT_BUCKET_SA="$APP_NAME-bucket-sa"
STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE="cicdbucketCustomRole.$VERSION"
# STARTUP_SCRIPT_NAME="$APP_NAME-startup-script.sh"

# For Notebook 
NOTEBOOK_REGION='us-central1'
RANGE_C='10.150.0.0/20'

#---------Database Credentials----------#
DB_CONTAINER_NAME="$APP_NAME-postgres-sql"
DB_NAME="$APP_NAME-admin"
DB_USER="$APP_NAME-admin" 
# DB_HOST=$(gcloud compute addresses describe $STATIC_IP_ADDRESS_NAME --region $REGION | grep "address: " | cut -d " " -f2)
DB_HOST=$(gcloud compute instances list --filter="name=$DB_INSTANCE_NAME" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 
DB_PORT=5000
DB_PASSWORD=$APP_NAME 
PROJECT_NAME="$(gcloud config get project)"
ADMIN_PASSWORD=$APP_NAME 
APP_PORT=9000
APP_ADDRESS=""
DOMAIN_NAME=""
SPECIAL_NAME=$APP_NAME 

#----------Deployment Environment Variables----------#
CLOUD_BUILD_REGION="us-west2"
REGION="us-west1" 
APP_ARTIFACT_NAME="$APP_NAME-artifact-registry"
APP_VERSION="latest"
APP_SERVICE_ACCOUNT_NAME="$APP_NAME-app-sa"
APP_CUSTOM_ROLE="cicdappCustomRole.$VERSION"
APP_PORT=9000
APP_ENV_FILE=".env.yaml"
MIN_INSTANCES=1
MAX_INSTANCES=1

echo "\n #----------Exporting Environment Variables is done.----------# \n"

# CI/CD GCP

#----------Source Repository and Trigger Environment Variables----------#
SA=$(gcloud config get project)
TRIGGER_NAME="ci-cd-gcp-trigger"
REPO="ci-cd-gcp-repo"
TRIGGER_REGION="us-central1"

# Create a Google Cloud Source Repository
gcloud source repos create $REPO

# Clone the project
gcloud source repos clone $REPO --project=$(gcloud config get project)

cd ci-cd-gcp-repo
cp -rf ~/ci-cd-gcp/app/* ~/ci-cd-gcp/ci-cd-gcp-repo

git add .
git commit -m "Add and modify files"
git push

#---------------------------Create a Cloud Build Trigger
# gcloud builds triggers create cloud-source-repositories --help
gcloud builds triggers create cloud-source-repositories \
    --repo="$REPO" \
    --branch-pattern="^master$" \
    --build-config="cloudbuild.yaml" \
    --region="$TRIGGER_REGION" \
    --name="$TRIGGER_NAME"
    # --service-account=projects/$SA/serviceAccounts/$SA@$SA.iam.gserviceaccount.com 

#---------------------------Grant Permissions
PROJECT_ID=$(gcloud config list --format='value(core.project)')
# Enable Cloud Resource Manager
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
# Grant Cloud Run Admin role to the CLoud Build service account
gcloud projects add-iam-policy-binding $(gcloud config list --format='value(core.project)') \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com \
    --role=roles/run.admin
# Grant the IAM Service Account User role to the Cloud Build service account for the Cloud Run runtime service account
#  gcloud iam service-accounts add-iam-policy-binding \
#    $(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')-compute@developer.gserviceaccount.com \
#    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com \
#    --role=roles/iam.serviceAccountUser
# Grant the IAM Service Account User role to the Cloud Build service account for the Cloud Run runtime service account
gcloud iam service-accounts add-iam-policy-binding \
    $APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

#--------------------------------Create a cloudbuild.yaml file
cat > cloudbuild.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
      gcloud builds submit \
      --region=$CLOUD_BUILD_REGION \
      --tag $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
    gcloud run deploy $APP_NAME \
    --max-instances=$MAX_INSTANCES --min-instances=$MIN_INSTANCES --port=$APP_PORT \
    --env-vars-file=$APP_ENV_FILE \
    --image=$REGION-docker.pkg.dev/$(gcloud config get project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION \
    --allow-unauthenticated \
    --region=$REGION \
    --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
EOF

# Environment Variables for the app
echo """
DB_NAME:
    '$DB_NAME'
DB_USER:
    '$DB_USER'
DB_HOST:
    '$DB_HOST'
DB_PORT:
    '$DB_PORT'
DB_PASSWORD:
    '$DB_PASSWORD'
PROJECT_NAME:
    '$PROJECT_NAME'
ADMIN_PASSWORD:
    '$ADMIN_PASSWORD'
APP_PORT:
    '$APP_PORT'
APP_ADDRESS:
    '$APP_ADDRESS'
DOMAIN_NAME:
    '$DOMAIN_NAME'
SPECIAL_NAME:
    '$SPECIAL_NAME'
""" > .env.yaml

git add .
git commit -m "Add and modify files"
git push



###################################################### Extra ###########################

# Build Template A
cat > cloudbuild_A.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/docker'
  script: |
    docker build -t us-central1-docker.pkg.dev/mattgcpprojects/ci-cd-gcp-i-artifact-registry/ci-cd-gcp-i:latest .
  automapSubstitutions: true
images:
- 'us-central1-docker.pkg.dev/mattgcpprojects/ci-cd-gcp-i-artifact-registry/ci-cd-gcp-i:latest'
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
    gcloud run deploy $APP_NAME \
    --max-instances=$MAX_INSTANCES --min-instances=$MIN_INSTANCES --port=$APP_PORT \
    --env-vars-file=$APP_ENV_FILE \
    --image=$REGION_B-docker.pkg.dev/$(gcloud config get project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION \
    --allow-unauthenticated \
    --region=$REGION \
    --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
EOF

# Build Template B
cat > cloudbuild_B.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
      gcloud builds submit \
      --region=$CLOUD_BUILD_REGION \
      --tag $REGION_B-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
    gcloud run deploy $APP_NAME \
    --max-instances=$MAX_INSTANCES --min-instances=$MIN_INSTANCES --port=$APP_PORT \
    --env-vars-file=$APP_ENV_FILE \
    --image=$REGION_B-docker.pkg.dev/$(gcloud config get project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION \
    --allow-unauthenticated \
    --region=$REGION \
    --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
EOF

