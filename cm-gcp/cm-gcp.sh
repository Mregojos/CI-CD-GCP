# Configuration Management on GCP

# Environment Variables
source cm-env.sh

# Configuration Management
sudo apt update 
sudo apt install ansible -y
ansible --version

# Try localhost
# ansible-playbook <playbook name>.yaml
# Using command module
ansible-playbook playbooks-localhost/localhost.yaml
# Using file module 
ansible-playbook playbooks-localhost/localhost.yaml

# Create a ssh key
ssh-keygen
echo $(cat ~/.ssh/id_rsa.pub)

# Create a startup script
cat > startup-script.sh << EOF
sudo apt update 
sudo apt install python3-pip -y
sudo apt install ansible -y
EOF

# Create a Compute Engine instances
source cm-env.sh
gcloud compute instances create vm-a vm-c --zone=$ZONE \
    --metadata-from-file=startup-script=startup-script.sh
    
# Create a Compute Engine instances with ssh-keys
source cm-env.sh
gcloud compute instances create vm-b --zone=$ZONE \
    --metadata-from-file=startup-script=startup-script.sh \
    --metadata=ssh-keys=$USER:"$(cat ~/.ssh/id_rsa.pub)"
    
# Create a Compute Engine instances adding SSH to vm a manually
source cm-env.sh
gcloud compute instances create vm-c --zone=$ZONE \
    --metadata-from-file=startup-script=startup-script.sh

# Use gcloud ssh to connect vm-a
gcloud compute ssh --zone $ZONE vm-a

# Add ip adresses to inventory
VM_A_IP=$(gcloud compute instances list --filter="name=vm-a" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
VM_B_IP=$(gcloud compute instances list --filter="name=vm-b" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
cat > inventory.txt <<EOF
[vms]
$VM_A_IP
$VM_B_IP
EOF

# Copy Public Key
cat ~/.ssh/id_rsa.pub
# Copy the key to vm-a
gcloud compute ssh --zone $ZONE vm-a
nano ~/.ssh/authorized_keys

# Test it
ssh $USER@$VM_A_IP
ssh $USER@$VM_B_IP

# Test using ping
ansible all -m ping -i inventory.txt -u $USER

# With inventory
# ansible-playbook <playbook name>.yaml -v <inventory>.yaml

# script.yaml
ansible-playbook playbooks-vms/script.yaml -i inventory.txt -u $USER

# Check the vm
gcloud compute ssh --zone $ZONE vm-a
# or
ssh $USER@$(gcloud compute instances list --filter="name=vm-a" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")


ssh $USER@$(gcloud compute instances list --filter="name=vm-b" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")





################################

# Create a password on instances
# Go to instances SSH
sudo passwd <USERNAME>
# Creat a new password

