# OCI Packaging with ocipack

Zero-dependency Go tool/library for packaging static binaries into minimal OCI image tarballs (OCI Image Spec 1.0).
Automatically bundles ca-certs and a `/tmp` dir; optionally tzdata.

Repo: `codeberg.org/fhuebner/ocipack`

## Adding as a Go tool dependency

```sh
go get -tool codeberg.org/fhuebner/ocipack/cmd/ocipack
```

This registers it in `go.mod` under the `tool` directive so `go tool ocipack` works in any checkout.

## Basic usage

```sh
CGO_ENABLED=0 go build -o myapp .
go tool ocipack myapp image.tar.gz
```

## Common flags

```
-tag ref               image reference (e.g. myapp:latest)
-user user[:group]     defaults to 65534 (nobody)
-entrypoint arg        repeatable
-env KEY=VALUE         repeatable
-label KEY=VALUE       repeatable
-add-file c:h[:mode]   add file: container-path:host-path[:mode], repeatable
-add-dir path[:mode]   add directory
-add-link path:target  add symlink
-no-cacerts            skip CA bundle
-no-tmp                skip /tmp
-tzdata                bundle /usr/share/zoneinfo from host
-created rfc3339       image timestamp (defaults to now)
```

## Loading the image

```sh
docker load -i image.tar.gz
podman load -i image.tar.gz
ctr images import image.tar.gz                                          # containerd
cp image.tar.gz /var/lib/rancher/k3s/agent/images/                     # k3s preload
skopeo copy oci-archive:image.tar.gz docker://registry.example.com/myapp:latest
```

## Reproducible builds

Pin all volatile sources to get a stable digest:

```sh
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
  -trimpath \
  -buildvcs=false \
  -ldflags="-s -w -buildid=" \
  -o myapp .

go tool ocipack \
  -created="1970-01-01T00:00:00Z" \
  -no-cacerts \
  myapp image.tar.gz
```

Omit `-tzdata` for reproducible images (host zoneinfo can change between distro upgrades).
