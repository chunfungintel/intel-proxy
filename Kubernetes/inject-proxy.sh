#!/bin/bash

K8S_OBJECT='deployment/x11-apps'
cat << EOF | kubectl set env $K8S_OBJECT --env -
http_proxy=http://proxy-png.intel.com:911
https_proxy=http://proxy-png.intel.com:912
ftp_proxy=http://proxy-png.intel.com:911
socks_proxy=http://proxy-png.intel.com:1080
no_proxy=10.226.76.0/23,192.168.0.0/24,10.107.248.110/22,.svc,.svc.cluster.local,10.244.0.0/16,10.96.0.0/16,localhost,istio-system.svc,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16,10.0.0.0/8,169.254.2.1/32,10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,172.16.0.0/12,134.134.0.0/16
HTTP_PROXY=http://proxy-png.intel.com:911
HTTPS_PROXY=http://proxy-png.intel.com:912
FTP_PROXY=http://proxy-png.intel.com:911
SOCKS_PROXY=http://proxy-png.intel.com:1080
NO_PROXY=10.226.76.0/23,192.168.0.0/24,10.107.248.110/22,.svc,.svc.cluster.local,10.244.0.0/16,10.96.0.0/16,localhost,istio-system.svc,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16,10.0.0.0/8,169.254.2.1/32,10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,172.16.0.0/12,134.134.0.0/16
EOF

