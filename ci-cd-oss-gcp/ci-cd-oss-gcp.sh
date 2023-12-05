# Jenkins
sh os.sh

# Open ports
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000,tcp:50000 --source-ranges=0.0.0.0/0

# Get the password
sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

# Exec container
sudo docker exec -it jenkins-blueocean sh
cd /var/jenkins_home/workspace

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
                echo "Clone the reo"
                
                export NAME="MATT"
                echo $NAME
                
                git clone https://github.com/mregojos/ci-cd-gcp
                
                ls
                
                cd ci-cd-oss-gcp
                
                ls
                
                
                """
            }
        }    
        stage ('Build') {
            steps {
                sh """
                echo "Build"
                
                gcloud builds submit \
                  --region=$CLOUD_BUILD_REGION \
                  --tag $REGION-docker.pkg.dev/$(gcloud config get-value project)/$APP_ARTIFACT_NAME/$APP_NAME:$APP_VERSION
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                echo "Deploy"
                """
            }
        }
    }
}

pipeline {
    agent any
    stages {
        stage ('Clone the repo') {
            steps {
                echo "Clone the repo"
                sh """
                NAME_ID="MATT"
                export NAME_ID="MATT"
                """
            }
        }    
        stage ('Build') {
            steps {
                sh """
                echo "Build"
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                echo "Deploy"
                """
            }
        }
    }
}