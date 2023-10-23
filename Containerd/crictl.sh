#!/bin/bash

cat <<EOF | sudo -E tee /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: true
EOF

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz
tar -zxvf crictl-v1.28.0-linux-amd64.tar.gz
sudo cp crictl /usr/local/bin/crictl
sudo chmod +x /usr/local/bin/crictl

