#!/usr/bin/env bash
#
# Based on:
#   https://soco.intel.com/docs/DOC-2192910
#   https://soco.intel.com/external-link.jspa?url=https%3A%2F%2Fwww.bounca.org%2Ftutorials%2Finstall_root_certificate.html
#   https://certificates.intel.com/PkiWeb/RAUI/TrustChain/RetrieveTrustChain.aspx
#   https://www.bounca.org/tutorials/install_root_certificate.html#linux-ubuntu-debian

set -e
source /etc/os-release
certsFile='IntelSHA2RootChain-Base64.zip'
certsUrl="http://certificates.intel.com/repository/certificates/$certsFile"
certsFolder=${PWD}/Intel
javaCerts=/etc/ssl/certs/java/cacerts

# backup
cp $javaCerts ${PWD}/java-cacerts

mkdir -p ${certsFolder}

downloadCerts(){
  if ! [ -x "$(command -v unzip)" ]; then
    echo 'Error: unzip is not installed.' >&2
    exit 1
  fi
  http_proxy='' &&\
    wget $certsUrl -O $certsFolder/$certsFile
  unzip -u $certsFolder/$certsFile -d $certsFolder
  rm $certsFolder/$certsFile
}

installCerts(){
  chmod 644 $certsFolder/*.crt
#  eval "$cmd"
  for file in ${PWD}/Intel/*crt; do
    filename=$(basename ${file})
    aliasname="${filename%.*}"
    echo $aliasname
    keytool -import -trustcacerts \
    -keystore /etc/ssl/certs/java/cacerts \
    -storepass changeit \
    -alias ${aliasname} \
    -file ${file}
  done
}

downloadCerts
installCerts

echo ""
echo "=================================================="
echo " IMPORTANT:"
echo " Java service MUST be restarted for Docker to "
echo " read and apply the new CAs."
echo "=================================================="
echo ""
