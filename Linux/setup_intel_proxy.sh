#!/usr/bin/env bash
#
# INTEL CONFIDENTIAL
# Copyright 2015 - 2020 Intel Corporation All Rights Reserved.
#
# The source code contained or described herein and all documents related
# to the source code ("Material") are owned by Intel Corporation or its
# suppliers or licensors. Title to the Material remains with Intel Corp-
# oration or its suppliers and licensors. The Material may contain trade
# secrets and proprietary and confidential information of Intel Corpor-
# ation and its suppliers and licensors, and is protected by worldwide
# copyright and trade secret laws and treaty provisions. No part of the
# Material may be used, copied, reproduced, modified, published, uploaded,
# posted, transmitted, distributed, or disclosed in any way without
# Intel's prior express written permission.
#
# No license under any patent, copyright, trade secret or other intellect-
# ual property right is granted to or conferred upon you by disclosure or
# delivery of the Materials, either expressly, by implication, inducement,
# estoppel or otherwise. Any license under such intellectual property
# rights must be express and approved by Intel in writing.
#

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
#
# Setup global environment variables
#
function AddProxyLine {
  newline=$1
  searchstring=$2
  addfile=$3
  #Check if /etc/environment already has that variable
  linenum="$(cat $addfile | grep -n ${searchstring} | grep -Eo '^[^:]+')"
  if [ "$?" -eq 0 ]; then
    #Sanitize the replacement line for sed
    safenewline="$(printf "${newline}" | sed -e 's/[\/&]/\\&/g')"
    #Actually do the replacement
    sudo sed -i "${linenum}s/.*/${safenewline}/" $addfile
  else
    #Append the line to the end of the file
    sudo bash -c "echo '${newline}' >> $addfile"
  fi
}
function AddAptLine {
  newline=$1
  searchstring=$2
  linenum=0
  replace=FALSE
  if [ -e /etc/apt/apt.conf ]; then
    linenum="$(cat '/etc/apt/apt.conf' | grep -n ${searchstring} | grep -Eo '^[^:]+')"
    if [ "$?" -eq 0 ]; then
      replace=TRUE
    fi
  fi
  if [ "$replace" = "TRUE" ]; then
    #Sanitize the replacement line for sed
    safenewline="$(printf "${newline}" | sed -e 's/[\/&]/\\&/g')"
    #Actually do the replacement
    sudo sed -i "${linenum}s/.*/${safenewline}/" /etc/apt/apt.conf
  else
    #Append the line to the end of the file
    sudo bash -c "echo '${newline}' >> /etc/apt/apt.conf"
  fi
}
AddProxyLine "http_proxy=http://${server}:911" "http_proxy" "/etc/environment"
AddProxyLine "https_proxy=http://${server}:912" "https_proxy" "/etc/environment"
AddProxyLine "ftp_proxy=http://${server}:911" "ftp_proxy" "/etc/environment"
AddProxyLine "socks_proxy=http://${server}:1080" "socks_proxy" "/etc/environment"
AddProxyLine "no_proxy=10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,172.16.0.0/12,134.134.0.0/16,10.226.76.0/23" "no_proxy" "/etc/environment"
#You have to duplicate upper-case and lower-case because some programs
#only look for one or the other
AddProxyLine "HTTP_PROXY=http://${server}:911" "HTTP_PROXY" "/etc/environment"
AddProxyLine "HTTPS_PROXY=http://${server}:912" "HTTPS_PROXY" "/etc/environment"
AddProxyLine "FTP_PROXY=http://${server}:911" "FTP_PROXY" "/etc/environment"
AddProxyLine "SOCKS_PROXY=http://${server}:1080" "SOCKS_PROXY" "/etc/environment"
AddProxyLine "NO_PROXY=10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,172.16.0.0/12,134.134.0.0/16,10.226.76.0/23" "NO_PROXY" "/etc/environment"

AddProxyLine "export http_proxy=http://${server}:911" "export http_proxy" "~/.bashrc"
AddProxyLine "export https_proxy=http://${server}:912" "export https_proxy" "~/.bashrc"
AddProxyLine "export ftp_proxy=http://${server}:911" "export ftp_proxy" "~/.bashrc"
AddProxyLine "export socks_proxy=http://${server}:1080" "export socks_proxy" "~/.bashrc"
AddProxyLine "export no_proxy=10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,172.16.0.0/12,134.134.0.0/16,10.226.76.0/23" "export no_proxy" "~/.bashrc"
#You have to duplicate upper-case and lower-case because some programs
#only look for one or the other
AddProxyLine "export HTTP_PROXY=http://${server}:911" "export HTTP_PROXY" "~/.bashrc"
AddProxyLine "export HTTPS_PROXY=http://${server}:912" "export HTTPS_PROXY" "~/.bashrc"
AddProxyLine "export FTP_PROXY=http://${server}:911" "export FTP_PROXY" "~/.bashrc"
AddProxyLine "export SOCKS_PROXY=http://${server}:1080" "export SOCKS_PROXY" "~/.bashrc"
AddProxyLine "export NO_PROXY=10.0.0.0/8,192.168.0.0/16,localhost,.local,127.0.0.0/8,172.16.0.0/12,134.134.0.0/16,10.226.76.0/23" "export NO_PROXY" "~/.bashrc"

AddAptLine "Acquire::http::Proxy \"http://${server}:911\";" "Acquire::http::Proxy"
AddAptLine "Acquire::ftp::Proxy \"http://${server}:911\";" "Acquire::ftp::Proxy"

#
# Some programs that support higher level APIs that enable autoproxy use.
# Setup autoproxy for those programs
#

#Check for the existance of gsettings
command -v gsettings >/dev/null 2>&1
if [ "$?" -eq 0 ]; then
  sudo gsettings set org.gnome.system.proxy mode 'auto'
  sudo gsettings set org.gnome.system.proxy autoconfig-url 'http://autoproxy.intel.com:9090'
  sudo gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '*.local', 'intel.com', '*.intel.com', '10.0.0.0/8', '192.168.0.0/16', '172.16.0.0/12', '134.134.0.0/16']"
  gsettings set org.gnome.system.proxy mode 'auto'
  gsettings set org.gnome.system.proxy autoconfig-url 'http://autoproxy.intel.com:9090'
  gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '*.local', 'intel.com', '*.intel.com', '10.0.0.0/8', '192.168.0.0/16', '172.16.0.0/12', '134.134.0.0/16']"
fi
echo 'Please reboot your system for changes to take effect'
