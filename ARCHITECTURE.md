# Local Compute Architecture

Based on our discussions, here is the finalized architecture for your local compute setup. This design prioritizes a minimal footprint while maximizing the performance of your hardware for AI-assisted development.

## 1. Hardware Distribution

### 🧠 Dedicated LLM Server: Framework Desktop
*   **Hardware:** AMD Ryzen AI Max+ 395 (Strix Halo) with 128GB LPDDR5x.
*   **Why:** With AMD Variable Graphics Memory, up to 96GB of unified memory can be allocated as VRAM. This is *massive* and allows you to comfortably serve highly capable, large coding models (like Llama 3 70B) natively. It completely outclasses the RTX 3080 in raw VRAM capacity.
*   **Role:** Exclusively runs the LLM inference engine to serve coding assistants (e.g., Continue.dev) in your IDE.

### 🏗️ Devcontainer Server: Intel NUC 12 Extreme
*   **Hardware:** Core i9 (RNUC12DCMi90001) + RTX 3080.
*   **Why:** Devcontainers require massive CPU thread counts for compiling, language servers, and running multiple Docker services simultaneously. The i9 excels here. The RTX 3080 provides excellent hardware acceleration if you ever need to test GPU-accelerated code or run secondary data processing tasks inside your containers.
*   **Role:** Bare-metal host for your Docker daemon. Your day-to-day machine will SSH into this box and spin up development environments seamlessly.

### 💻 Day-to-Day Orchestrator: Framework Laptop Board
*   **Hardware:** Framework Laptop Board in Cooler Master Case.
*   **Why:** Quiet, power-efficient, and fully capable of driving your main displays and handling web browsing, VS Code UI, and terminal sessions.
*   **Role:** Your daily driver. You will run your IDE here, but offload the actual compute (language servers, compilers) to the Intel NUC, and the AI completion queries to the Framework Desktop.

*(Note: The Ayaneo AM02 is omitted from the critical path and can be repurposed for home automation, media, or sold.)*

## 2. Software Stack

### Base OS (Servers)
*   **Ubuntu Server (or Debian):** Installed bare-metal on both the Framework Desktop and the Intel NUC. Keeping it bare-metal avoids virtualization overhead and ensures the GPU/APU resources are fully available to Docker and Ollama.

### LLM Serving
*   **Ollama:** Installed on the Framework Desktop. Ollama provides a dead-simple, OpenAI-compatible API out of the box. 
*   **Recommended Models:** `llama3`, `deepseek-coder-v2`, or `codestral`.

### Container Management
*   **Docker Engine:** Installed on the Intel NUC. 
*   **VS Code / Devcontainers:** You will use the standard Devcontainers extension to attach to the remote Docker daemon on the NUC.

## 3. Network Architecture
*   **Local Network Routing:** Since everything is physically local, you will rely on your standard LAN.
*   **DHCP Reservations:** Assign static IPs via your router to the Framework Desktop (`llm-server`) and the Intel NUC (`dev-server`).
*   **SSH & Tunneling:** You will use plain SSH keys for authentication. Traffic to containers will be routed via standard SSH tunneling and your `brotherlogic/dcrouter` setup, maintaining the "pure" UNIX networking approach without needing Tailscale overlays.

## 4. Recommended Next Steps

1.  **Provision the Servers:** Install Ubuntu Server on the NUC and Framework Desktop. Ensure you configure static IPs or MAC reservations on your router.
2.  **Setup SSH Keys:** Generate an SSH keypair on your Framework Laptop Board and copy it to `~/.ssh/authorized_keys` on both servers.
3.  **Install Docker:** Run the standard Docker installation script on the Intel NUC.
4.  **Install Ollama:** Install Ollama on the Framework Desktop and download a test model (e.g., `ollama run llama3`). Ensure the Ollama service is configured to bind to `0.0.0.0` so it accepts connections from your local network.
5.  **Configure IDE:** On your Framework Laptop board, install the 'Dev Containers' and 'Continue.dev' extensions. Configure the Dev Containers extension to use the NUC's Docker host, and configure Continue.dev to point to the Framework Desktop's local IP on port 11434.
