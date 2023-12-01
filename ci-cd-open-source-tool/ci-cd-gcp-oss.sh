# cloud.google.com/cli
sh ci-cd-oss-gcloud.sh

# firewall
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000 --source-ranges=0.0.0.0/0
# Open IP:8000

# password
docker exec <CONTAINER_ID> cat /var/jenkins_home/secrets/initialAdminPassword

# App Env
cd app
# DB_INSTANCE_NAME Address / Host
DB_HOST=$(gcloud compute instances list --filter="name=$DB_INSTANCE_NAME" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 

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

cd ..

# Example Pipeline
pipeline {
    agent any
    stages {
        stage ('Build') {
            steps {
                sh """
                  gcloud builds submit \
                      --region=$CLOUD_BUILD_REGION \
                      --tag $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
                """
            }
        }    
        stage ('Test') {
            steps {
                sh """
                gcloud config list
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                    gcloud run deploy $APP_NAME \
                        --max-instances=$MAX_INSTANCES --min-instances=$MIN_INSTANCES --port=$APP_PORT \
                        --env-vars-file=$APP_ENV_FILE \
                        --image=$REGION-docker.pkg.dev/$(gcloud config get project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION \
                        --allow-unauthenticated \
                        --region=$REGION \
                        --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
                """
            }
        }
    }
}

#-------------------------
pipeline {
    agent any
    stages {
        stage ('Clone repository') {
            steps {
                sh """
                https://github.com/mregojos/ci-cd-gcp
                cd ci-cd-open-source-tool/app
                """
            }
        }    
        stage ('Build') {
            steps {
                sh """
                gcloud builds submit --region=us-west2 --tag us-west1-docker.pkg.dev/matt---project/ci-cd-gcp-oss-i-artifact-registry/ci-cd-gcp-oss-i:latest
                """
            }
        }    
        stage ('Test') {
            steps {
                sh """
                gcloud config list
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                   gcloud run deploy ci-cd-gcp-oss-i     --max-instances=1 --min-instances=1 --port=9000     --env-vars-file=.env.yaml     \
                       --image=us-west1-docker.pkg.dev/matt---project/ci-cd-gcp-oss-i-artifact-registry/ci-cd-gcp-oss-i:latest     --allow-unauthenticated     \
                       --region=us-west1     --service-account=ci-cd-gcp-oss-i-app-sa@matt---project.iam.gserviceaccount.com 
                """
            }
        }
    }
}