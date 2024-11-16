#!/bin/bash

#Requires Twinny https://twinnydotdev.github.io/twinny-docs/general/quick-start/
# https://marketplace.visualstudio.com/items?itemName=rjmacarthy.twinny
# Launch VS Code Quick Open (Ctrl+P), paste the following command, and press enter.
# ext install rjmacarthy.twinny

#only install ollama if not installed
which ollama || curl -fsSL https://ollama.com/install.sh | sh || exit 1

ollama serve &

sleep 2

# use /bye after each model starts up
ollama run codellama:7b-instruct
ollama run codellama:7b-code
