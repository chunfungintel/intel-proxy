#!/bin/bash

echo "NTP=ntp-fm11d.cps.intel.com 10.128.4.200 10.128.4.201 corp.intel.com" | sudo tee -a /etc/systemd/timesyncd.conf
sudo timedatectl set-timezone Asia/Singapore
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-timesyncd
sudo systemctl restart systemd-timesyncd

