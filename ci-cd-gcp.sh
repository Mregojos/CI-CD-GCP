# Environment
SA=$(gcloud config get project)
REPO="ci-cd-gcp-repo"

# Create a Google Cloud Source Repository
gcloud source repos create $REPO

# Clone the project
gcloud source repos clone $REPO --project=$(gcloud config get project)

cd ci-cd-gcp-repo
cp -rf ~/ci-cd-gcp/app/* ~/ci-cd-gcp/ci-cd-gcp-repo
git add .
git commit -m "Add and modify files"
git push

# Create a Cloud Build Trigger
gcloud builds triggers create cloud-source-repositories --name=ci-cd-gcp-trigger \
    --service-account=$SA@$SA.iam.gserviceaccount.com
    --branch-pattern=".*"
    --repo=$REPO
    --build-config=

