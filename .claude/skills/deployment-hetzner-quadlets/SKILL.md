---
name: deployment-hetzner-quadlets
description: Design, create, review, or modify production deployments on Hetzner Cloud. Use for hcloud-based provisioning, Debian servers, cloud-init, Podman Quadlets, nginx reverse proxy, certbot HTTPS, firewall setup, and lightweight operational runbooks.
---

Hetzner Cloud is the provider of choice.
The human user must supply the `hcloud` API token.
Prompt user for all unresolved placeholders.

Prefer the latest stable versions of OS and tools.

Create resources via `hcloud`.

## Server

When creating a new server:

- Use `templates/cloud-init.yaml` for initial configuration.
- Always use `Debian`.

## Quadlets

Run containers via `Podman` configured as [
`Quadlets`](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).

Use these templates for creating config files:

- `templates/systemd.container`
- `templates/systemd.network`

## Reverse Proxy

Use `nginx` as the reverse proxy,

Use configuration file `templates/nginx.conf` as template for the nginx site config.

The nginx `proxy_pass` port must match the `PublishPort` of the container.

This is the first trusted proxy in the chain, so we overwrite the `X-Forwarded-For` header.

### Certbot

Use certbot to obtain a Let's Encrypt certificate for HTTPS.

Make sure certbot renews the certificate automatically.
