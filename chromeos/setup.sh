# setup local git
./set_git_config.sh

# setup github
./install-gh-cli.sh
gh auth login

# install vscode
./install-vscode.sh

# install nodejs
./install-node.sh

# install antigravity
./install-antigravity.sh

# install chrome (required for antigravity agent browser)
./install-chrome.sh
