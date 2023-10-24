#!/bin/bash

PS3='Select the closest proxy server to this system: '
proxys=("United States" "India" "Israel" "Ireland" "Germany" "Malaysia" "China")
select proxy in "${proxys[@]}"
do
  case $proxy in
    "United States")
      server="proxy-us.intel.com"
      break
      ;;
    "India")
      server="proxy-iind.intel.com"
      break
      ;;
    "Israel")
      server="proxy-iil.intel.com"
      break
      ;;
    "Ireland")
      server="proxy-ir.intel.com"
      break
      ;;
    "Germany")
      server="proxy-mu.intel.com"
      break
      ;;
    "Malaysia")
      server="proxy-png.intel.com"
      break
      ;;
    "China")
      server="proxy-prc.intel.com"
      break
      ;;
    *) echo "Invalid proxy";;
  esac
done

sudo mkdir -p /etc/systemd/system/containerd.service.d

cat <<EOF | sudo -E tee /etc/systemd/system/containerd.service.d/http_proxy.conf
[Service]
Environment="HTTP_PROXY=http://${server}:911/"
Environment="HTTPS_PROXY=http://${server}:912/"
Environment="NO_PROXY=localhost,.intel.com"
EOF
sudo systemctl daemon-reload && sudo systemctl restart containerd.service

