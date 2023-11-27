# Environment
#----------Artifact Registry Environment Variables----------#
VERSION="i"
APP_NAME="ci-cd-gcp-$VERSION"
REGION="us-west1"
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
REPO="ci-cd-gcp-repo"
TRIGGER_NAME="ci-cd-gcp-trigger"

# Create a Google Cloud Source Repository
gcloud source repos create $REPO

# Clone the project
gcloud source repos clone $REPO --project=$(gcloud config get project)

cd ci-cd-gcp-repo
cp -rf ~/ci-cd-gcp/app/* ~/ci-cd-gcp/ci-cd-gcp-repo

# Create a cloudbuild.yaml file
cat > cloudbuild.yaml <<EOF
steps:
- name: 'gcr.io/cloud-builders/docker'
  script: |
    docker build -t $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION .
  automapSubstitutions: true
    
images:
- '$REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION'

steps:
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

git add .
git commit -m "Add and modify files"
git push

# Create a Cloud Build Trigger
gcloud builds triggers create cloud-source-repositories --name=$TRIGGER_NAME \
    --service-account="$SA@$SA.iam.gserviceaccount.com" \
    --branch-pattern=".*" \
    --repo="$REPO" \
    --build-config="cloudbuild.yaml"

