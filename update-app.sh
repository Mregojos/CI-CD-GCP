# Model Deployment Repo
# cp -rf app-deployment/* ~/ci-cd-gcp/app
cp -rf app-deployment/Main.py ~/ci-cd-gcp/app
cp -rf app-deployment/pages/Agent.py ~/ci-cd-gcp/app/pages
cp -rf test/* ~/ci-cd-gcp/test
cp -rf makefile ~/ci-cd-gcp/makefile

# ci-cd-gcp oss
cp -rf app ci-cd-oss-gcp

# Infrastructure Automation GCP Repo
# cp -rf infrastructure-automation-gcp.sh ~/ci-cd-gcp
# cp -rf cleanup.sh ~/ci-cd-gcp
