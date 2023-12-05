cat > pipeline.txt << EOF
# Clone the repo, build, deploy
pipeline {
    agent any
    environment {
        PROJECT="$(gcloud config get-value project)"
    }
    stages {
        stage ('Clone Repository') {
            steps {
                echo "Clone the repo"
                sh """
                git clone https://github.com/mregojos/ci-cd-gcp
                cd ci-cd-gcp/ci-cd-oss-gcp/app
                pwd
                """

            }
        }    
        stage ('Build') {
            steps {
                sh """
                pwd
                cd ci-cd-gcp/ci-cd-oss-gcp/app
                pwd
                gcloud builds submit --region=$CLOUD_BUILD_REGION --tag $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                pwd
                cd ci-cd-gcp/ci-cd-oss-gcp/app
                pwd
                gcloud run deploy $APP_NAME --max-instances=$MAX_INSTANCES --min-instances=$MIN_INSTANCES --port=$APP_PORT --env-vars-file=$APP_ENV_FILE --image=$REGION-docker.pkg.dev/$(gcloud config get project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION --allow-unauthenticated --region=$REGION --service-account=$APP_SERVICE_ACCOUNT_NAME@$(gcloud config get project).iam.gserviceaccount.com 
                """
            }
        }
    }
}

EOF

# DB_INSTANCE_NAME Address / Host
DB_HOST=$(gcloud compute instances list --filter="name=$DB_INSTANCE_NAME" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 

cat > app/env.yaml << EOF
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

EOF