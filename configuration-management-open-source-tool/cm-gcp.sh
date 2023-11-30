# Configuration Management on GCP

# Environemnt Variable
ZONE="us-west1-a"
PLAYBOOK_NAME=""
USERNAME=""

# Configuration Management
sh cm.sh

# Try localhost
# ansible-playbook <playbook name>.yaml
ansible-playbook playbooks/localhost.yaml

# Create a ssh key
ssh-keygen
cat ~/.ssh/id_rsa.pub

# Create two Compute Engine instances
gcloud compute instances create vm-a vm-b --zone=$ZONE

# Copy the key to other machines
mkdir ~/.ssh
nano ~/.ssh/authorized_keys

# Test it
ssh $USERNAME@$IP_ADDRESS

# Test using ping
ansible all -m ping -i inventory.txt

# With inventory
# ansible-playbook <playbook name>.yaml -v <inventory>.yaml
ansible-playbook $PLAYBOOK_NAME.yaml -v inventory.txt
