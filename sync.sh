#!/bin/bash

robot="nao01.local"

echo "Sync keys"
mkdir -p keys
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
fi

ssh nao@$robot "mkdir -p ~/.ssh"
cat ~/.ssh/id_rsa.pub | ssh nao@$robot "cat >> ~/.ssh/authorized_keys"

echo "Placing files"
cp src/build-robo/sdk/bin/rinobot root/home/nao/
cp src/build-robo/sdk/lib/libagent.so root/home/nao/naoqi/preferences/libagent.so

echo "Sync root"
rsync -aburvP --rsync-path="sudo rsync" root/etc nao@$robot:/
echo "Sync home"
rsync -aurvP root/home/nao/ nao@$robot:~/

echo "Turning off services we do not use"
# Add back in then delete because delete throws error if not installed
#  * Networking connection manager replaced with runswiftwireless above
ssh nao@$robot "sudo rc-update add connman boot"
ssh nao@$robot "sudo rc-update del connman boot"
ssh nao@$robot "sudo rc-update add qimessaging-json default"
ssh nao@$robot "sudo rc-update del qimessaging-json default"

ssh nao@$robot "nao restart"