# Configuration Management for the App

# Environment Variables
source cm-env.sh

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
    - name: test (get)
      command: gcloud storage cp gs://$BUCKET_NAME/startup-script.sh .
    - name: list objects
      command: gcloud storage ls
    - name: test (write/create)
      command: gcloud storage cp file.txt gs://$BUCKET_NAME/
EOF

# Create a ssh key if not yet created
ssh-keygen
echo $(cat ~/.ssh/id_rsa.pub)

# Add metadata ssh-keys to the app
gcloud compute instances add-metadata $APP_NAME-db --metadata=ssh-keys=$USER:"$(cat ~/.ssh/id_rsa.pub)" --zone=$ZONE

# Add ip adressess to inventory
APP_DB_IP=$(gcloud compute instances list --filter="name=$APP_NAME-db" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
cat > app-inventory.txt << EOF
[vms]
$APP_DB_IP
EOF

# Open SSH
SOURCE_IP=$(gcloud compute instances list --filter="name="$USERNAME"" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
gcloud compute --project=$(gcloud config get project) firewall-rules create $FIREWALL_RULES_NAME-ssh \
    --direction=INGRESS --priority=1000 --network=$VPC_NAME --action=ALLOW --rules=tcp:22 --source-ranges=$SOURCE_IP/32 \
    --target-tags=$TAGS

# Test using ping
ansible all -m ping -i app-inventory.txt -u $USER

#---------------------------------------------------------
# Option A
# Add IAM Policy binding (STORAGE ADMIN)
gcloud projects add-iam-policy-binding $(gcloud config get project) \
    --member=serviceAccount:$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com \
    --role=roles/storage.admin

# Option B
# Update role
# gcloud iam roles describe roles/storage.objectUser
gcloud iam roles update $STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE \
    --project=$(gcloud config get project) \
    --permissions=storage.objects.get,storage.objects.create,storage.objects.update,storage.objects.list,storage.buckets.get,storage.buckets.create,storage.buckets.update,\
storage.buckets.list
    
# gcloud iam roles describe $STARTUP_SCRIPT_BUCKET_CUSTOM_ROLE --project=$(gcloud config get project) 


# with playbook
ansible-playbook data-bucket.yaml -i app-inventory.txt -u $USER

# SSH
ssh $USER@$(gcloud compute instances list --filter="name=$APP_NAME-db" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
# or
gcloud compute ssh $APP_NAME-db --zone $ZONE



#-------------------------Cleanup---------------------------------------#
gcloud compute firewall-rules delete $FIREWALL_RULES_NAME-ssh --quiet

# Remove IAM Policy binding
gcloud projects remove-iam-policy-binding $(gcloud config get project) \
    --member=serviceAccount:$STARTUP_SCRIPT_BUCKET_SA@$(gcloud config get project).iam.gserviceaccount.com \
    --role=roles/storage.admin
    
    
    