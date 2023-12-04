########### Copy SQL Data to Bucket
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
export BUCKET_NAME="$APP_NAME-startup-script"
cat > data-bucket.yaml << EOF
---
- hosts: vms
  name: Using Command Module
  tasks:
    - name: gcloud version
      command: gcloud version
    - name: create a file
      file:
        name: file.txt
        state: touch
    - name: copy data to cloud storage
      command: gcloud storage cp file.txt gs://$BUCKET_NAME
EOF

# Add metadata ssh-keys to the app
source cm-env.sh
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
gcloud compute instances add-metadata $APP_NAME-db --metadata=ssh-keys=$USER:"$(cat ~/.ssh/id_rsa.pub)" --zone=$ZONE

# Add ip adressess to inventory
source cm-env.sh
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
APP_DB_IP=$(gcloud compute instances list --filter="name=$APP_NAME-db" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
cat > app-inventory.txt << EOF
[vms]
$APP_DB_IP
EOF

# Open SSH
export USERNAME="" # This VM Name
source cm-env.sh
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
export FIREWALL_RULES_NAME="$APP_NAME-ports"
export VPC_NAME="$APP_NAME-vpc"
export TAGS="db"
SOURCE_IP=$(gcloud compute instances list --filter="name="$USERNAME"" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-ssh \
    --direction=INGRESS --priority=1000 --network=$VPC_NAME --action=ALLOW --rules=tcp:22 --source-ranges=$SOURCE_IP/32 \
    --target-tags=$TAGS

# Test using ping
ansible all -m ping -i app-inventory.txt -u $USER

# Add IAM Policy binding
source cm-env.sh
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
export STARTUP_SCRIPT_BUCKET_SA="$APP_NAME-bucket-sa"
gcloud compute instances ad-iam-policy-binding $APP_NAME-db --zone $ZONE \
    --member=serviceAccount:$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com \
    --role=roles/storage.objectUser

# with playbook
ansible-playbook data-bucket.yaml -i app-inventory.txt -u $USER

# SSH
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
ssh $USER@$(gcloud compute instances list --filter="name=$APP_NAME-db" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
# or
source cm-env.sh
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
gcloud compute ssh $APP_NAME-db --zone $ZONE

##### Cleanup
export VERSION="i"
export APP_NAME="ci-cd-oss-gcp-$VERSION"
export FIREWALL_RULES_NAME="$APP_NAME-ports"
gcloud compute firewall-rules delete $FIREWALL_RULES_NAME-ssh --quiet