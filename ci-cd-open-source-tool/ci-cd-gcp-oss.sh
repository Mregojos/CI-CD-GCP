# cloud.google.com/cli
sh ci-cd-oss-gcloud.sh

# firewall
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000 --source-ranges=0.0.0.0/0
# Open IP:8000

# password
docker exec <CONTAINER_ID> cat /var/jenkins_home/secrets/initialAdminPassword

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