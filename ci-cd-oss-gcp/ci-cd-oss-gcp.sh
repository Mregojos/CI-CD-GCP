# Jenkins
sh os.sh

# Open ports
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-oss \
    --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8000,tcp:50000 --source-ranges=0.0.0.0/0

# Get the password
sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword

# Exec container
sudo docker exec -it jenkins-blueocean sh
cd /var/jenkins_home/workspace/pipeline
rm -rf ci*

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
    environment {
        PROJECT=""
    }
    stages {
        stage ('Clone the repo') {
            steps {
                echo "Clone the repo"
                sh """
                echo "${env.PROJECT}"
                git clone https://github.com/mregojos/ci-cd-gcp
                cd ci-cd-gcp/ci-cd-oss-gcp/app
                pwd
                """

            }
        }    
        stage ('Build') {
            steps {
                sh """
                cd ci-cd-gcp/ci-cd-oss-gcp/app
                gcloud builds submit --region=us-west2 --tag us-west1-docker.pkg.dev/mattsreproject/ci-cd-oss-gcp-i-artifact-registry/ci-cd-oss-gcp-i:latest
                """
            }
        }
        stage ('Deploy') {
            steps {
                sh """
                cd ci-cd-gcp/ci-cd-oss-gcp/app
                gcloud run deploy ci-cd-oss-gcp-i  --max-instances=1 --min-instances=1 --port=9000  --env-vars-file=env.yaml     \
                --image=us-west1-docker.pkg.dev/mattsreproject/ci-cd-oss-gcp-i-artifact-registry/ci-cd-oss-gcp-i:latest     --allow-unauthenticated     \
                --region=us-west1     --service-account=ci-cd-oss-gcp-i-app-sa@mattsreproject.iam.gserviceaccount.com 
                """
            }
        }
    }
}