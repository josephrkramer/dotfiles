#!/bin/bash
set -euo pipefail

export GO_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1)

echo "Installing the go version ${GO_VERSION}..."

# Returns just the version string (e.g., go1.26.0)

export GO_TARBALL="${GO_VERSION}.linux-amd64.tar.gz"
wget "https://go.dev/dl/${GO_TARBALL}"

sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $GO_TARBALL
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

rm $GO_TARBALL

#verify go installation
go version

# Optional (for full stack mode)
sudo apt install -y tmux

# Install Gas Town CLI
go install github.com/steveyegge/gastown/cmd/gt@latest

# Install Beads (issue tracker)
go install github.com/steveyegge/beads/cmd/bd@latest

# Verify installation
gt version
bd version

# Create a Gas Town workspace (HQ)
gt install ~/gt --shell

# This creates:
#   ~/gt/
#   ├── CLAUDE.md          # Identity anchor (run gt prime)
#   ├── mayor/             # Mayor config and state
#   ├── rigs/              # Project containers (initially empty)
#   └── .beads/            # Town-level issue tracking

# Verify installation
cd ~/gt

gt enable              # enable Gas Town system-wide
gt git-init            # initialize a git repo for your HQ
gt up                  # Start all services. Use gt down or gt shutdown for stopping. 

gt doctor              # Run health checks
gt status              # Show workspace status