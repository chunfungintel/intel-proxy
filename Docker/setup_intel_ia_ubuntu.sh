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

echo "setup docker proxy"
sudo systemctl stop docker

sudo mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF | sudo -E tee /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://${server}:911/"
Environment="HTTPS_PROXY=http://${server}:912/"
Environment="NO_PROXY=localhost,.intel.com"
EOF

mkdir -p ~/.docker
echo "{
        \"auths\": {
                \"gar-registry.caas.intel.com\": {
                        \"auth\": \"anN1bjMyOld5bGRzajclRmViMjAyMA==\"
                }
        },
        \"HttpHeaders\": {
                \"User-Agent\": \"Docker-Client/19.03.7 (linux)\"
        },
        \"proxies\": {
                \"default\": {
                        \"httpProxy\": \"http://${server}:911\",
                        \"httpsProxy\": \"http://${server}:912\",
                        \"noProxy\": \"intel.com,.intel.com,10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,134.134.0.0/16\"
                }
        }
}" > ~/.docker/config.json

# Docker DNS inside Intel
cat << EOF | sudo -E tee  /etc/docker/daemon.json
{
    "dns": ["10.248.2.1"],
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
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
    exit 1
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

sudo systemctl daemon-reload

sudo systemctl restart docker

echo 'Please reboot your system for changes to take effect'
