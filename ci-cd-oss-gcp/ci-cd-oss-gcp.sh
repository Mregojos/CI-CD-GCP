# ci-cd-oss-gcp directory

# Build Infra
source environment-variables.sh
sh infrastructure-automation-gcp.sh

# Jenkins
sh os.sh

# Open ports
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000,tcp:50000 --source-ranges=0.0.0.0/0

# Get the password and go to <VM IP Address>:8000
sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

# Exec container
sudo docker exec -it jenkins-blueocean sh

# Create a pipelie and env variables
# Note: use env.yaml not .env.yaml
sh pipeline.sh
# Push to repository 
# ci-cd-gcp directory
sh g*
# Go to UI and create a pipeline using pipeline.txt

# Don't forget to cleanup
source environment-variables.sh
sh cleanup.sh
rm -rf pipeline.txt
rm -rf app/env.yaml


#---------------------------- Simple pipeline for testing
pipeline {
    agent any
    stages {
        stage ('Test-A') {
            steps {
                echo "It's working."
            }
        }
        stage ('Test-B') {
            steps {
                sh """
                pwd
                """
            }
        }        
    }
}

# Test gcloud cli
pipeline {
    agent any
    stages {
        stage ('Test gcloud cli') {
            steps {
                sh """
                gcloud config list
                """
            }
        }
    }
}



