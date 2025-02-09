#!/bin/bash
curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
chmod +x nodesource_setup.sh
sudo ./nodesource_setup.sh
rm nodesource_setup.sh
sudo apt install -y nodejs
