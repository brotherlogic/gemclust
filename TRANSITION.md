# Transition Plan: Migrating to the New Architecture

This guide outlines the step-by-step process to safely migrate your devcontainer environment (managed by `brotherlogic/devcontainer-manager`) from your Framework Desktop to the Intel NUC, ensuring you maintain uninterrupted access to your development environments, before finally repurposing the Framework Desktop as your LLM server.

## Phase 1: Provision the Intel NUC (The New Dev Server)

Before touching your existing setup on the Framework Desktop, we will prepare the Intel NUC.

1. **Install Base OS:** Install Ubuntu Server (or Debian) on the Intel NUC. 
2. **Assign Static IP:** On your local router, assign a static IP to the Intel NUC (e.g., `192.168.1.100`).
3. **Setup SSH Access:** 
   - From your **Framework Laptop Board** (your new day-to-day orchestrator), generate an SSH key if you haven't already (`ssh-keygen`).
   - Copy the public key to the Intel NUC (`ssh-copy-id user@<NUC-IP>`).
4. **Provision via Ansible:** Use the Ansible scripts in this repository to configure the NUC.
   - Copy `ansible/inventory.yml.template` to `ansible/inventory.yml`.
   - Update `ansible/inventory.yml` with the correct IP and user for the Intel NUC.
   - **Note:** You may need to validate the SSH connection and accept the host key before running Ansible. You can do this by running `ssh-keyscan -H <NUC-IP> >> ~/.ssh/known_hosts` or by SSHing into the machine manually once.
   - Confirm Ansible can connect: `ansible dev_servers -m ping -i ansible/inventory.yml`
   - Run the setup playbook: `ansible-playbook -i ansible/inventory.yml ansible/site.yml --limit dev_servers`
   *(This will automatically install Docker and clone `devcontainer-manager`).*

## Phase 2: Migrate `devcontainer-manager`

Now we will stand up your devcontainers on the new hardware alongside the old hardware.

1. **Verify the Manager:** On the **Intel NUC**, ensure Ansible successfully cloned your management repo:
   ```bash
   cd ~/devcontainer-manager
   git status
   ```
2. **Setup Dotfiles:** All dotfiles are managed by chezmoi. Initialize and apply them on the Intel NUC:
   ```bash
   chezmoi init --apply brotherlogic
   ```
   *(Replace `brotherlogic` with your GitHub username if different, or install chezmoi first if not present).*
3. **Transfer State (If necessary):** If your `devcontainer-manager` relies on any local state or specific volume mounts on the Framework Desktop (excluding dotfiles), `rsync` those directories over to the Intel NUC.
   ```bash
   rsync -avz user@<Framework-Desktop-IP>:/path/to/data/ /local/path/on/nuc/
   ```
4. **Spin Up Containers:** Run your `devcontainer-manager` deployment scripts on the Intel NUC to pull the images and spin up your devcontainers on the new hardware. 
   - *At this point, you have identical devcontainers running on both the Framework Desktop and the Intel NUC.*

## Phase 3: Switch the Orchestrator (Cutover)

We will now redirect your day-to-day machine to talk to the new Intel NUC instead of the old Framework Desktop.

1. **Update `dcrouter`:** On your **Framework Laptop Board** (Orchestrator), update your `brotherlogic/dcrouter` configuration. 
   - Change the underlying SSH tunnels or routing tables so that requests meant for devcontainers now point to the Intel NUC's IP address instead of the Framework Desktop's IP.
2. **Update SSH Config:** If you use `~/.ssh/config` for container aliases, ensure the `HostName` or `ProxyCommand` directives now resolve through the Intel NUC.
3. **Verify Access:** Open VS Code on the Framework Laptop Board and connect to your devcontainers. Ensure that you are landing in the containers hosted on the Intel NUC. Test compilation or run a script to confirm performance and connectivity.

## Phase 4: Repurpose the Framework Desktop (LLM Server)

Once you have verified that your dev workflow is fully operational on the Intel NUC, you can repurpose the Framework Desktop.

1. **Teardown Old Environment:** On the **Framework Desktop**, stop and remove the old devcontainers to free up resources:
   ```bash
   docker stop $(docker ps -a -q)
   docker system prune -a --volumes
   ```
   *(Optional: You can completely uninstall Docker if you want to keep this machine purely for LLMs).*
2. **Provision LLM Server via Ansible:** Use the Ansible scripts to install and configure Ollama.
   - Ensure you have copied `ansible/inventory.yml.template` to `ansible/inventory.yml` and updated it with the IP of the Framework Desktop under `llm_servers`.
   - **Note:** You may need to validate the SSH connection and accept the host key before running Ansible. You can do this by running `ssh-keyscan -H <Framework-Desktop-IP> >> ~/.ssh/known_hosts` or by SSHing into the machine manually once.
   - Run the setup playbook: `ansible-playbook -i ansible/inventory.yml ansible/site.yml --limit llm_servers`
   *(This will automatically install Ollama, configure network bindings, and pull the `deepseek-coder-v2` model).*

## Phase 5: Final Integration

1. **Connect IDE to LLM:** On your **Framework Laptop Board** (Orchestrator), open the configuration for your AI assistant extension (e.g., `config.json` for Continue.dev).
2. **Point to Framework Desktop:** Update the API base URL to point to the Framework Desktop:
   ```json
   "models": [
     {
       "title": "Ollama DeepSeek",
       "provider": "ollama",
       "model": "deepseek-coder-v2",
       "apiBase": "http://<Framework-Desktop-IP>:11434"
     }
   ]
   ```

You are now fully migrated to the new architecture!
