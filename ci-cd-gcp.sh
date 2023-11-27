# Create a Google Cloud Source Repository
gcloud source repos create ci-cd-gcp-repo

# Clone the project
gcloud source repos clone ci-cd-gcp-repo --project=$(gcloud config get project)

cd ci-cd-gcp-repo
cp -rf ~/ci-cd-gcp/app/* ~/ci-cd-gcp/ci-cd-gcp-repo
git add .
git commit -m "Add and modify files"
git push

