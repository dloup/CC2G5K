#!/bin/bash

set -x
set -e

## Get arguments ##
if [ $# -lt 2 ]; then
  echo "Needs at least 2 args : g5k2CC [ubuntu|centos] source_image [output name]"
  exit 1
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NORMAL='\033[0m'

SOURCE_OS=$1
SOURCE_IMG=$2
OUTPUT_IMG=${3:-out.tgz}

cp $SOURCE_IMG tmp.qcow2

if [ $SOURCE_OS == "ubuntu" ]; then
  DHCP_HOOK=/etc/dhcp/dhclient-exit-hooks.d/
elif [ $SOURCE_OS == "centos" ]; then
  DHCP_HOOK=/etc/dhcp/dhclient.d/
else
  echo "Only ubuntu and centos based image supported"
  exit 1
fi

virt-copy-in -a tmp.qcow2 g5k-update-host-name $DHCP_HOOK
virt-tar-out -a tmp.qcow2 / - | gzip --best > $OUTPUT_IMG
virt-ls -a tmp.qcow2 /boot > boot_folder_content

if [ $? -eq 0 ]; then
  echo -e "$GREEN Image successfully exported. $NORMAL
For the description file, you can start from one of a default g5k environment based on the same OS:
For exemle, for a Ubuntu based image, start from the output of this command:
>kaenv3 -p ubuntu14.04-x64-min
$YELLOW you may need the path to vmlinuz and initrd to write the description file, the content of /boot is in 'boot_folder_content $NORMAL'"
else
  echo "$RED Something went wrong $NORMAL"
fi

rm tmp.qcow2
