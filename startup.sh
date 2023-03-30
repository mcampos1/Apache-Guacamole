#!/bin/bash
echo "Starting the gaucamole swarm..."
sudo docker compose up -d
echo "Complete."
echo
echo "Modifying volume mount permissions..."
sudo chmod a+rwx data
sudo chmod a+rwx drive
sudo chmod a+r ./nginx/ssl/self-ssl.key
sudo chmod a+r ./nginx/ssl/self.cert
echo "Complete"
echo
echo "Execute 'docker ps' to verify containers are up and running."
