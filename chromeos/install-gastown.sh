#!/bin/bash
set -euo pipefail

LATEST_GO_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1)
CURRENT_GO_VERSION=$(go version 2>/dev/null | awk '{print $3}' || true)

if [ "$CURRENT_GO_VERSION" != "$LATEST_GO_VERSION" ]; then
    echo "Installing/Updating Go to ${LATEST_GO_VERSION} (Current: ${CURRENT_GO_VERSION:-none})..."
    export GO_TARBALL="${LATEST_GO_VERSION}.linux-amd64.tar.gz"
    wget -q "https://go.dev/dl/${GO_TARBALL}" -O "/tmp/${GO_TARBALL}"

    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "/tmp/${GO_TARBALL}"
    rm "/tmp/${GO_TARBALL}"
else
    echo "Go ${LATEST_GO_VERSION} is already installed."
fi

# Ensure Go is in PATH for this script and future shells
GO_PATH_EXPORT='export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
if ! grep -qFx "$GO_PATH_EXPORT" ~/.bashrc; then
    echo "$GO_PATH_EXPORT" >> ~/.bashrc
fi
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

#verify go installation
go version

# Optional (for full stack mode)
if ! command -v tmux &> /dev/null; then
    sudo apt update && sudo apt install -y tmux
fi

# Install Gas Town CLI
go install github.com/steveyegge/gastown/cmd/gt@latest

# Install Beads (issue tracker)
go install github.com/steveyegge/beads/cmd/bd@latest

# Verify installation
gt version
bd version

# Create a Gas Town workspace (HQ)
if [ ! -d "$HOME/gt" ]; then
    gt install ~/gt --shell
fi

# Verify installation
cd ~/gt

# These commands are assumed to be idempotent or safe to re-run
gt enable              # enable Gas Town system-wide
if [ ! -d ".git" ]; then
    gt git-init            # initialize a git repo for your HQ
fi
gt up                  # Start all services. Use gt down or gt shutdown for stopping. 

gt doctor              # Run health checks
gt status              # Show workspace status