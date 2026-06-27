# Local Compute Infrastructure Ansible

This directory contains the Ansible playbooks to provision your bare-metal servers for your local compute setup.

## Prerequisites
1. Install Ansible on your orchestrator machine:
   `sudo apt install ansible`
2. Ensure you have installed Ubuntu Server manually on both the Framework Desktop and the Intel NUC, and that they are accessible via SSH.
3. Update `inventory.yml` with the correct IP addresses and the default SSH user you created during OS installation.

## Running the Playbook
To apply the configuration to all machines, run:
```bash
ansible-playbook -i inventory.yml site.yml -K
```
*(The `-K` flag will prompt you for the sudo password so Ansible can install packages on the remote hosts).*
