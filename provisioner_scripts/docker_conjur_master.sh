#!/bin/bash
## Installing Docker
sleep 10
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
#sudo usermod -aG docker centos
sudo -E sh -c 'systemctl enable docker'
sudo -E sh -c 'systemctl start docker'

## Installing Docker Compose
sudo -E sh -c 'curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose'
sudo -E sh -c 'chmod +x /usr/local/bin/docker-compose'
sudo -E sh -c 'sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose'

## Starting Conjur Master
#sudo -E sh -c 'docker load -i /tmp/conjur-appliance-11.2.1.tar.gz'
#echo "[INFO] Starting DAP master"
#sudo -E sh -c 'docker-compose -f /tmp/docker-compose/docker-compose.yaml up -d dap-master'

## Starting Conjur CLI
#echo "[INFO] Starting DAP CLI"
#sudo -E sh -c 'docker-compose -f /tmp/docker-compose/docker-compose.yaml up -d dap-cli'

