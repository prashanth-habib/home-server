## Home Server with Docker Compose
This repository provides a **Docker Compose-based home server setup** with essential self-hosting tools:
1. [Pi-hole](https://pi-hole.net/) - Network-wide ad blocker & DNS server
2. [Nginx Proxy Manager](https://nginxproxymanager.com/) – Reverse proxy with SSL management
3. [Portainer](https://www.portainer.io/) – Docker management UI

Two stacks are included:
- `core-apps/` → The **main infrastructure stack**
- `stack-1/` → A secondary stack of apps/service build on main infrastructure stack which can be maintained by Portainer.

### Repository Structure
home-server/  
├── core-apps/  
│   ├── compose.yaml            # Core apps: Pi-hole, Nginx Proxy Manager, Portainer  
│   └── npm-init/  
│       └── init-proxy-hosts.sh # Script to initialize proxy hosts in NPM  
├── stack-1/  
│   ├── compose.yml             # Alternative stack (same apps)  
│   └── resources/              # Additional resources (custom images, configs)  
└── Readme.md                   # This file  

### Prerequisites
- **Operating System:**
  - Tested on **Ubuntu 22.04 LTS (Linux)**
  - Should work on other Linux distributions with Docker installed
  - Windows is not officially tested.
    - If using Windows, you’ll need **Docker Desktop with WSL2**.
    - Some networking features (like custom DNS resolution) may not work exactly the same as Linux.
  - **Required software:**
    - [Docker Engine](https://docs.docker.com/engine/install/)
    - [Docker Compose Plugin](https://docs.docker.com/compose/install/linux/)
  - Also read [Disable systemd-resolved port 53](https://docs.pi-hole.net/docker/tips-and-tricks/)

### Setup Instructions
1. Clone the repository   
    ```
    git clone https://github.com/<your-username>/home-server.git
    cd home-server/core-apps
    ```
2. Create a `.env` file
In `core-apps/` (and/or `stack-1/`), create a `.env` file with your own values:  
    ```
    # Example .env file
    HOST_IP=192.168.1.100     # Your host machine's LAN IP
    PIHOLE_PASS=yourpiholepassword
    NPM_USER=admin@example.com
    NPM_PASS=yournpmadminpass
    ```
> [!TIP]
> You can find your host IP using:
> ```
> ip route get 1.1.1.1 | awk '{print $7; exit}'
> ```

3. Start the stack 
    ```
    docker compose up -d
    ```
This will start Pi-hole, Nginx Proxy Manager, Portainer, and initialize default proxy hosts.   

4. Access the services   

| Service              | URL                             | Credentials                     |
|----------------------|---------------------------------|---------------------------------|
| Nginx Proxy Manager  | `http://npm.home.lan`           | `${NPM_USER}` / `${NPM_PASS}`   |
| Portainer            | `http://portainer.home.lan`     | Set up on first login           |
| Pi-hole              | `http://pihole.home.lan/admin`  | `${PIHOLE_PASS}`                |

### Customization
- Modify **DNS & proxy hostnames** in `compose.yaml` under Pi-hole environment variables.
- Adjust proxy hosts by editing `npm-init/init-proxy-hosts.sh`.
- Use `stack-1/` for deploying more apps/service built on top of `core-apps/`.

### Tear Down
To stop and remove containers (while keeping data volumes):
```
docker compose down
```
To remove everything including volumes:
```
docker compose down -v
```

### Notes & Caveats
- Designed and tested **only on Ubuntu/Linux**.
- May work on **Windows (Docker Desktop + WSL2)** but untested. Networking behavior (especially LAN DNS resolution) might differ.
- Ensure your router/DNS settings point to the host running Pi-hole for full network-wide blocking.