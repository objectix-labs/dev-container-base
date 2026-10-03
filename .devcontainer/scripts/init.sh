#!/bin/bash
# Initialize the temporary development container environment. This environment is
# used to store temporary files and environment variables needed for the development container.
rm -rf .devcontainer/tmp
mkdir -p .devcontainer/tmp

# Export host's current GitHub token if available
if which gh &>/dev/null; then
    gh auth token | xargs -I {} echo "GH_TOKEN="{} > .devcontainer/tmp/.env.devcontainer
fi