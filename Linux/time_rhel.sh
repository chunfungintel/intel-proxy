#!/bin/bash

cat << EOF | sudo tee -a /etc/chrony.conf
server ntp-fm11d.cps.intel.com iburst
server 10.128.4.200 iburst
server 10.128.4.201 iburst
server corp.intel.com iburst
EOF
sudo timedatectl set-timezone Asia/Singapore
sudo systemctl daemon-reload && sudo systemctl restart chronyd

