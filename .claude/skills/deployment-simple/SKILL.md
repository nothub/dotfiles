---
name: deployment-simple
description: Design, create, review, or modify simple production deployments for small services on Hetzner Cloud. Use for hcloud-based provisioning, Debian servers, cloud-init, systemd networking, Podman containers, Quadlets, nginx reverse proxy setup, certbot-managed HTTPS, firewall basics, deployment files, and lightweight operational runbooks.
---

Hetzner Cloud is the provider of choice.
The human user must supply the `hcloud` API token.
The human user must supply a public ssh key for ssh access.

Prefer the latest stable versions of OS and tools.

Create resources via `hcloud`.

Always use `Debian`.

Configure servers via `cloud-init` and declarative `systemd` config files.

Run containers via `Podman` configured as [`Quadlets`](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).

Use `nginx` as the reverse proxy, LetsEncrypt certs via `certbot` for HTTPS.
