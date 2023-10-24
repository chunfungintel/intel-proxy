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

echo "setup containerd proxy"
sudo systemctl stop containerd.service

sudo mkdir -p /etc/systemd/system/containerd.service.d

cat <<EOF | sudo -E tee /etc/systemd/system/containerd.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${server}:911/"
Environment="HTTPS_PROXY=http://${server}:912/"
Environment="NO_PROXY=localhost,.intel.com"
EOF

#source /etc/os-release
certsFile='IntelSHA2RootChain-Base64.zip'
certsUrl="http://certificates.intel.com/repository/certificates/$certsFile"
 
certsFolder='/usr/local/share/ca-certificates'
#certsFolder='/etc/pki/ca-trust/source/anchors/'
cmd='/usr/sbin/update-ca-certificates'
#cmd='update-ca-trust'
 
downloadCerts(){
  if ! [ -x "$(command -v unzip)" ]; then
    echo 'Error: unzip is not installed.' >&2
    sudo apt install -y unzip
    #exit 1
  fi
  http_proxy='' &&\
  sudo -E wget $certsUrl -O $certsFolder/$certsFile
  sudo -E unzip -u $certsFolder/$certsFile -d $certsFolder
  sudo -E rm $certsFolder/$certsFile
}
 
installCerts(){
  sudo chmod 644 $certsFolder/*.crt
  sudo -sE eval "$cmd"
}
 
#mkdir -p /usr/local/share/ca-certificates
downloadCerts
installCerts

sudo mkdir -p /etc/containerd
sudo containerd config default |& sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl daemon-reload
sudo systemctl restart containerd.service

echo 'Please reboot your system for changes to take effect'
