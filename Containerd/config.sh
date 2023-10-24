#!/bin/bash

sudo mkdir -p /etc/containerd
sudo containerd config default |& sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl daemon-reload && sudo systemctl restart containerd.service

