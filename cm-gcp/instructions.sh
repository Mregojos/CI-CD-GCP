# add hosts here (create if there's no directory): /etc/ansible/hosts
# sudo nano /etc/ansible/hosts
ansible all --list-hosts

# Set up SSH Connections
# To generate SSH Key
ssh-keygen
# cd ~/.ssh/
cat ~/.ssh/id_rsa.pub

# Copy the key to another machine
nano .ssh/authorized_keys

# Test it
ssh <USERNAME>@<External_IP>

# Test Ansible ping
ansible all -m ping -u <USERNAME>