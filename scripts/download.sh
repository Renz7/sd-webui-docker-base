#!/bin/bash

echo "########################################"
echo "Downloading SD-WebUI & components..."
echo "########################################"

set -euxo pipefail

cd /home/runner
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

mkdir -p /home/runner/stable-diffusion-webui/extensions
cd /home/runner/stable-diffusion-webui/extensions

git clone https://github.com/numz/sd-wav2lip-uhq.git \
    sd-wav2lip-uhq

cd /home/runner/stable-diffusion-webui
aria2c --allow-overwrite=false --auto-file-renaming=false --continue=true \
    --max-connection-per-server=5 --input-file=/home/scripts/download.txt
