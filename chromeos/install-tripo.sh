#!/bin/bash
set -euo pipefail

sudo apt update
sudo apt install -y python3-pip

cd ~

git clone https://github.com/VAST-AI-Research/TripoSR.git
cd TripoSR

python3 -m venv .venv
source .venv/bin/activate

pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cpu

pip install --upgrade setuptools
pip install -r requirements.txt
