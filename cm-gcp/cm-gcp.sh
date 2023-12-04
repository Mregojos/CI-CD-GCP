# Configuration Management on GCP

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

# Create two Compute Engine instances
gcloud compute instances create vm-a vm-b --zone=$ZONE \
    --metadata-from-file=startup-script=startup-script.sh

gcloud compute ssh --zone $ZONE vm-a

# Add ip adresses to inventory
vm_a_ip=$(gcloud compute instances list --filter="name=vm-a" --format="value(networkInterfaces[0].accessConfigs[0].natIP)") 
vm_b_ip=$(gcloud compute instances list --filter="name=vm-b" --format="value(networkInterfaces[0].accessConfigs[0].natIP)" )
cat > inventory.txt <<EOF
[servers]
$vm_a_ip
$vm_b_ip
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
