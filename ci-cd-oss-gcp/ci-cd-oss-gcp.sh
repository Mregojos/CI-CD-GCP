# Jenkins
sh os.sh

# Open ports
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000,tcp:50000 --source-ranges=0.0.0.0/0

# Get the password
sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

# Simple pipeline
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

# Clone the repo, build, deploy
pipeline {
    agent any
    stages {
        stage ('Clone the repo') {
            steps {
                sh """
                git clone https://github.com/mregojos/ci-cd-gcp
                
                """
            }
        }    
        stage ('Build') {
            steps {
                sh """
                
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                ### Script
                """
            }
        }
    }
}
