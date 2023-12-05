# Jenkins
sh os.sh

# Open ports
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000,tcp:50000 --source-ranges=0.0.0.0/0

# Get the password
sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

# Exec container
sudo docker exec -it jenkins-blueocean sh

# Create a pipelie and env variables
sh pipeline.sh
# Push to repository
sh g*
# Go to UI and create a pipeline

# Don't forget to cleanup
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



