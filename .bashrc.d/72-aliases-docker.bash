# shellcheck shell=bash

alias docker-jupyter="docker run -it --rm \
    --name=jupyter \
    -v \"\${HOME}:/home/jovyan/home\" \
    -p 8888:8888 \
    jupyter/scipy-notebook:latest"

alias docker-trivy="docker run -it --rm \
    --name=trivy \
    -v \"/tmp/trivy-cache:/root/.cache\" \
    -v \"/var/run/docker.sock:/var/run/docker.sock\" \
    aquasec/trivy image"
