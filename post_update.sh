#!/bin/sh


set username="paperless"
set fullname="paperless-ngx"
set appname="paperless-ngx"
set uid=1000
set gid=1000
set home="/home/paperless"

### fetch paperless-ngx
cd ${home}

sudo -Hu ${username} fetch https://github.com/paperless-ngx/paperless-ngx/releases/download/v2.8.1/paperless-ngx-v2.8.1.tar.xz && \
sudo -Hu ${username} tar -xf paperless-ngx-v2.8.1.tar.xz


### fetch prebuild wheels
# sudo -Hu ${username} fetch https://github.com/hellvesper/iocage-plugin-paperless-ngx/releases/download/v2.7.2%4013.2-RELEASE/wheels.tar.xz
sudo -Hu ${username} tar -xf wheels.tar.xz

### rename wheels, because it python store os version from 'uname -r' which is TrueNAS base os version
cp /root/rename.sh ./
chown ${username}:${username} rename.sh
sudo -Hu ${username} /bin/sh rename.sh

### install wheels
setenv PATH ${PATH}:/home/${username}/.local/bin
sudo -Hu ${username} python3.11 -m ensurepip --upgrade
sudo -Hu ${username} cp ${appname}/requirements.txt ./
sudo -Hu ${username} sed -i '' 1d requirements.txt

cp /root/install_wheels.sh ./
setenv PATH ${PATH}:/home/${username}/.local/bin
chown ${username}:${username} install_wheels.sh
sudo -Hu ${username} /bin/sh install_wheels.sh
# pip3.11 install --no-build-isolation pyyaml==6.0.1