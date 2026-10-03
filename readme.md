# Dev Container Base

A generic, reusable [Dev Container](https://containers.dev/) setup intended as a starting point for new projects. It provides an Ubuntu-based development environment with Node.js, the GitHub CLI and [Claude Code](https://claude.com/claude-code) preinstalled, and passes your host's GitHub credentials into the container automatically.

## What's included

| Component | Details |
| --- | --- |
| Base image | `mcr.microsoft.com/devcontainers/base:ubuntu` |
| System packages | `nano`, `curl`, `git`, `wget`, `ca-certificates`, `unzip` |
| User | Non-root user `vscode` |
| Shell | Zsh with Oh My Zsh (default shell) |
| Environment | `DEVCONTAINER=true`, `CLAUDE_CONFIG_DIR=/home/vscode/.claude` |

### Dev container features

Versions are pinned in `.devcontainer/devcontainer-lock.json`.

| Feature | Version |
| --- | --- |
| `ghcr.io/devcontainers/features/node:1` | 1.7.1 |
| `ghcr.io/anthropics/devcontainer-features/claude-code:1.0` | 1.0.5 |
| `ghcr.io/devcontainers/features/github-cli:1` | 1.1.3 |
| `ghcr.io/devcontainers/features/common-utils:2` | 2.7.0 |

### VS Code extensions

- `anthropic.claude-code` – Claude Code
- `shd101wyy.markdown-preview-enhanced` – Markdown Preview Enhanced

## Prerequisites

- Docker (Docker Desktop, OrbStack, or Docker Engine)
- VS Code with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension, or the [`devcontainer` CLI](https://github.com/devcontainers/cli)
- The [GitHub CLI](https://cli.github.com/) installed **on the host** and logged in:

  ```sh
  gh auth login
  ```

## Getting started

1. Clone this repository (or copy the `.devcontainer/` folder into your project).
2. Open the folder in VS Code.
3. Run **Dev Containers: Reopen in Container** from the command palette.

Alternatively, using the CLI:

```sh
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
```

## How it works

The container lifecycle uses two scripts in `.devcontainer/scripts/`:

1. **`init.sh`** (`initializeCommand`, runs on the **host** before the container starts)
   Recreates `.devcontainer/tmp/` and writes the host's GitHub token (`gh auth token`) as `GH_TOKEN` into `.devcontainer/tmp/.env.devcontainer`.
2. The env file is passed to the container via `runArgs` (`--env-file`), so `GH_TOKEN` is available inside the container and `gh` is authenticated automatically.
3. **`setup-dev-container.sh`** (`postCreateCommand`, runs **inside** the container after creation)
   Configures Git to use the GitHub CLI as credential helper for `https://github.com`, so `git push`/`git pull` work without extra login.

`.devcontainer/tmp/` is listed in `.gitignore`, so the token is never committed. It is regenerated every time the container is started.

## Claude Code configuration

Claude Code's configuration directory (`/home/vscode/.claude`) is stored in the named Docker volume `claude-code-config`. Your login, settings and history therefore survive container rebuilds.

Note that the volume name is fixed, so all containers created from this template share the same Claude Code configuration. To reset it, remove the volume while no container is using it:

```sh
docker volume rm claude-code-config
```

## Customizing

Look for the `TODO` markers in the configuration files:

- **`.devcontainer/devcontainer.json`**
  - `name` – set a name reflecting your project's use case
  - `features` – add further [dev container features](https://containers.dev/features)
  - `customizations.vscode.extensions` – add further VS Code extensions
- **`.devcontainer/Dockerfile`**
  - `FROM` – choose a different base image if needed
  - `apt-get install` – add further system packages

After changing the configuration, run **Dev Containers: Rebuild Container**. When adding or upgrading features, the lock file `.devcontainer/devcontainer-lock.json` is updated accordingly – commit it together with your changes.

## Project structure

```text
.
├── .devcontainer/
│   ├── Dockerfile                  # Base image and system packages
│   ├── devcontainer.json           # Dev container configuration
│   ├── devcontainer-lock.json      # Pinned feature versions
│   ├── scripts/
│   │   ├── init.sh                 # Host: exports GH_TOKEN into env file
│   │   └── setup-dev-container.sh  # Container: Git credential helper setup
│   └── tmp/                        # Generated at startup (git-ignored)
├── .gitignore
└── readme.md
```

## Troubleshooting

- **Container fails to start because `.devcontainer/tmp/.env.devcontainer` is missing**
  `init.sh` only writes the env file when `gh` is installed on the host (the `tmp/` folder is wiped on every start, so creating the file manually does not help). Install the GitHub CLI on the host and run `gh auth login`.

- **`gh` or `git push` reports authentication errors inside the container**
  Check `gh auth status` inside the container. If the host token has changed or expired, re-authenticate on the host (`gh auth login`) and rebuild/restart the container so a fresh token is exported.
