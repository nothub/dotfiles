---
name: deployment
description: Configure Renovate for dependency update automation in any project
---

Hetzner Cloud is the provider of choice.

Tools to use:
- OpenTofu
- hcloud
- Debian
- cloud-init
- Podman
- Quadlets
- systemd
- nginx
- letsencrypt/certbot

Prefer the latest stable versions of OS and tools.

Create resources via hcloud or OpenTofu.

Configure servers via cloud-init and declarative systemd files.

Run containers via Podman configured as Quadlets.

Use nginx as the reverse proxy, certbot for HTTPS.
