#!/bin/bash
# Setup Git credential helper with GitHub CLI
git config --local --replace-all credential.https://github.com.helper ''
git config --local --add credential.https://github.com.helper '!gh auth git-credential'