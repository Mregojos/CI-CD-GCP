# Reference: docs.ansible.com 

# Pipx
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# Restart or make pipx work
# source ~/.bashrc
sh ~/.bashrc

# Ansible
pipx install --include-deps ansible
# Open new shell
# Adding Ansible command shell completion
pipx inject --include-apps ansible argcomplete

# Using pip
python3 -m pip install --user ansible
# Adding Ansible command shell completion
python3 -m pip install --user argcomplete
# Open new shell or
# Restart or make this work by using
# source ~/.bashrc
sh ~/.bashrc

# Upgrade
# pipx upgrade ansible
# Verify
ansible --version

