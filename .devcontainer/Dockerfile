# TODO: Set the base image to use for the devcontainer.
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USERNAME=vscode
ENV DEVCONTAINER=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    nano \
    curl \
    git \
    wget \
    ca-certificates \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace /home/${USERNAME}/.claude && \
  chown -R ${USERNAME}:${USERNAME} /workspace /home/${USERNAME}/.claude

WORKDIR /workspace
USER ${USERNAME}
