#!/bin/bash

wget https://gitlab.devtools.intel.com/caas-public/general/-/raw/master/scripts/ca_install.sh
chmod a+x ca_install.sh
sudo ./ca_install.sh

sudo systemctl daemon-reload
sudo systemctl restart docker
