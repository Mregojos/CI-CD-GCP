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
cat ~/.ssh/id_rsa.pub

# Create a startup script
cat > startup-script.sh << EOF
sudo apt update 
sudo apt install python3-pip -y
sudo apt install ansible -y
# TO DO: Create a user
# Public key
touch ~/.ssh/authorized_keys
echo "$(cat ~/.ssh/id_rsa.pub)" >>  ~/.ssh/authorized_keys
EOF

# Create a Compute Engine instances
gcloud compute instances create vm-a --zone=$ZONE \
    --metadata-from-file=startup-script=startup-script.sh

# Use gcloud ssh to connect
# gcloud compute ssh --zone $ZONE vm-a

# Add ip adresses to inventory
vm_a_ip=$(gcloud compute instances list --filter="name=vm-a" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 
cat > inventory.txt <<EOF
[vms]
$vm_a_ip
EOF

# Copy the key to other machines
mkdir ~/.ssh
nano ~/.ssh/authorized_keys

# Test it
ssh $USERNAME@$IP_ADDRESS

# Test using ping
ansible all -m ping -i inventory.txt -u $USERNAME

# With inventory
# ansible-playbook <playbook name>.yaml -v <inventory>.yaml

# servers.yaml
ansible-playbook playbooks/$PLAYBOOK_NAME.yaml -i inventory.txt -u $USERNAME

# Create a password on instances
# Go to instances SSH
sudo passwd <USERNAME>
# Creat a new password

# Try to connet via SSH
ssh $USERNAME@$(gcloud compute instances list --filter="name=vm-a" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 

# apt.yaml
ansible-playbook playbooks/apt.yaml -i inventory.txt -u $USERNAME
