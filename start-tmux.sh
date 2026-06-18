#!/bin/bash

# Ensure the 'prod' session exists
if ! tmux has-session -t gemclust 2>/dev/null; then
  # Create a new session named 'prod', detached
  cd /workspaces/gemclust
  tmux new-session -d -s gemclust
fi
