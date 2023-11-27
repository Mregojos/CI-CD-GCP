# Environment Variables
#----------Artifact Registry Environment Variables----------#
VERSION="i"
APP_NAME="ci-cd-gcp-$VERSION"
REGION="us-west1"
REGION_B="us-central1"
APP_ARTIFACT_NAME="$APP_NAME-artifact-registry"
APP_VERSION="latest"

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

#----------Source Repository and Trigger Environment Variables----------#
SA=$(gcloud config get project)
TRIGGER_NAME="ci-cd-gcp-trigger"
REPO="ci-cd-gcp-repo"

# Create a Google Cloud Source Repository
gcloud source repos create $REPO

# Clone the project
gcloud source repos clone $REPO --project=$(gcloud config get project)

cd ci-cd-gcp-repo
cp -rf ~/ci-cd-gcp/app/* ~/ci-cd-gcp/ci-cd-gcp-repo

# Create a cloudbuild.yaml file
cat > cloudbuild.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
      gcloud builds submit \
      --region=$CLOUD_BUILD_REGION \
      --tag $REGION_B-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
    
images:
- '$REGION_B-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION'

steps:
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

gcloud artifacts repositories create $APP_ARTIFACT_NAME \
    --repository-format=docker \
    --location=$REGION_B \
    --description="Docker repository"
echo "\n #----------Artifact Repository has been successfully created.----------# \n"

# Create a Cloud Build Trigger
# gcloud builds triggers create cloud-source-repositories --help
gcloud builds triggers create cloud-source-repositories \
    --repo="$REPO" \
    --branch-pattern="^master$" \
    --build-config="cloudbuild.yaml" \
    --region="$REGION_B" \
    --name="$TRIGGER_NAME"
    
    # --service-account=projects/$SA/serviceAccounts/$SA@$SA.iam.gserviceaccount.com \

# Grant Permissions
PROJECT_ID=$(gcloud config list --format='value(core.project)')
# Enable Cloud Resource Manager
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
# Grant Cloud Run Admin role to the CLoud Build service account
gcloud projects add-iam-policy-binding $(gcloud config list --format='value(core.project)') \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com \
    --role=roles/run.admin
# Grant the IAM Service Account User role to the Cloud Build service account for the Cloud Run runtime service account
gcloud iam service-accounts add-iam-policy-binding \
    $(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')-compute@developer.gserviceaccount.com \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser
# Grant the IAM Service Account User role to the Cloud Build service account for the Cloud Run runtime service account
gcloud iam service-accounts add-iam-policy-binding \
    $APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser
    

# Build Template 1
cat > cloudbuild.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/docker'
  script: |
    docker build -t us-central1-docker.pkg.dev/mattgcpprojects/ci-cd-gcp-i-artifact-registry/ci-cd-gcp-i:latest .
  automapSubstitutions: true
images:
- 'us-central1-docker.pkg.dev/mattgcpprojects/ci-cd-gcp-i-artifact-registry/ci-cd-gcp-i:latest'
steps:
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

cat > cloudbuild.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/gcloud'
  script: |
      gcloud builds submit \
      --region=$CLOUD_BUILD_REGION \
      --tag $REGION_B-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
    
images:
- '$REGION_B-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION'

steps:
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