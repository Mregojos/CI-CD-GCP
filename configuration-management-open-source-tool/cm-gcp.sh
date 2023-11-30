# Configuration Management on GCP

# Configuration Management
sh cm.sh

# Try localhost
# ansible-playbook <playbook name>.yaml
ansible-playbook playbooks/localhost.yaml

# With inventory
# ansible-playbook <playbook name>.yaml -v <inventory>.yaml
ansible-playbook <playbook name>.yaml -v <inventory>.yaml
