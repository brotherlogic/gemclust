# Transition Plan: Migrating to the New Architecture

This guide outlines the step-by-step process to safely migrate your devcontainer environment (managed by `brotherlogic/devcontainer-manager`) from your Framework Desktop to the Intel NUC, ensuring you maintain uninterrupted access to your development environments, before finally repurposing the Framework Desktop as your LLM server.

## Phase 1: Provision the Intel NUC (The New Dev Server)

Before touching your existing setup on the Framework Desktop, we will prepare the Intel NUC.

1. **Install Base OS:** Install Ubuntu Server (or Debian) on the Intel NUC. 
2. **Assign Static IP:** On your local router, assign a static IP to the Intel NUC (e.g., `192.168.1.100`).
3. **Setup SSH Access:** 
   - From your **Framework Laptop Board** (your new day-to-day orchestrator), generate an SSH key if you haven't already (`ssh-keygen`).
   - Copy the public key to the Intel NUC (`ssh-copy-id user@<NUC-IP>`).
4. **Install Docker:** Run the standard Docker installation on the Intel NUC.
   - Ensure your user is added to the `docker` group (`sudo usermod -aG docker $USER`).

## Phase 2: Migrate `devcontainer-manager`

Now we will stand up your devcontainers on the new hardware alongside the old hardware.

1. **Clone the Manager:** On the **Intel NUC**, clone your management repo:
   ```bash
   git clone https://github.com/brotherlogic/devcontainer-manager.git
   cd devcontainer-manager
   ```
2. **Transfer State (If necessary):** If your `devcontainer-manager` relies on any local state, dotfiles, or specific volume mounts on the Framework Desktop, `rsync` those directories over to the Intel NUC.
   ```bash
   rsync -avz user@<Framework-Desktop-IP>:/path/to/data/ /local/path/on/nuc/
   ```
3. **Spin Up Containers:** Run your `devcontainer-manager` deployment scripts on the Intel NUC to pull the images and spin up your devcontainers on the new hardware. 
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
2. **Install Ollama:** Install the Ollama service on the Framework Desktop:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
3. **Configure Network Binding:** By default, Ollama only listens on `localhost`. You need to expose it to your local network.
   - Edit the systemd service: `sudo systemctl edit ollama.service`
   - Add the following under the `[Service]` block:
     ```ini
     [Service]
     Environment="OLLAMA_HOST=0.0.0.0"
     ```
   - Restart the service: `sudo systemctl daemon-reload && sudo systemctl restart ollama`
4. **Pull Models:** Pull your desired coding models:
   ```bash
   ollama run deepseek-coder-v2
   ```

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
