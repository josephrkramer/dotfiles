#!/bin/bash

#Requires Continue https://www.continue.dev/
# https://github.com/continuedev/continue
# https://marketplace.visualstudio.com/items?itemName=Continue.continue
# Launch VS Code Quick Open (Ctrl+P), paste the following command, and press enter.
# ext install Continue.continue

mkdir ~/.continue
cp config.json ~/.continue/.

#only install ollama if not installed
which ollama || curl -fsSL https://ollama.com/install.sh | sh || exit 1

ollama serve &

sleep 2

ollama pull llama3.1:8b
ollama pull starcoder2:3b
