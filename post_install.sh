#!/bin/tcsh


echo "install paperless"

echo "Fetch and install paperless"


# Define the username and other details
set username="paperless"
set fullname="paperless-ngx"
set appname="paperless-ngx"
# set uid=1001
# set gid=1001
set home="/home/paperless"
# set shell="/bin/bash"

# Create group
# /usr/sbin/pw groupadd ${username}

# Create the user
# /usr/sbin/pw useradd ${username} -n ${fullname} -u ${uid} -g ${gid} -m -s ${shell}

pw groupadd ${username} && pw useradd -n ${username} -m -g ${username} -s /bin/sh -d ${home}

# Set a password for the new user
#echo "newuser:password" | /usr/sbin/chpass

# Optionally, add the user to a group
#/usr/sbin/pw groupmod staff -m ${username}

# cp /root/paperless-ngx /home/paperless-ngx/
# chown paperless-ngx:paperless-ngx /home/paperless-ngx

chown -R ${username}:${username} ${home}/${appname}

# mkdir ${home}/paperless-data/media
# mkdir ${home}/paperless-data/data
# mkdir ${home}/paperless-data/consume

# chown -R ${username}:${username} ${home}/paperless-data


mkdir /mnt/media
mkdir /mnt/data
mkdir /mnt/consume

chown -R ${username}:${username} /mnt/media
chown -R ${username}:${username} /mnt/data
chown -R ${username}:${username} /mnt/consume


### fetch paperless-ngx
cd ${home}

sudo -Hu paperless fetch https://github.com/paperless-ngx/paperless-ngx/releases/download/v2.7.2/paperless-ngx-v2.7.2.tar.xz && \
sudo -Hu paperless tar -xf paperless-ngx-v2.7.2.tar.xz


### fetch prebuild wheels
sudo -Hu paperless fetch https://github.com/hellvesper/iocage-plugin-paperless-ngx/releases/download/v2.7.2%4013.2-RELEASE/wheels.tar.xz
sudo -Hu paperless tar -xf wheels.tar.xz

### rename wheels, because it python store os version from 'uname -r' which is TrueNAS base os version
cp /root/rename.sh ./
chown ${username}:${username} rename.sh
sudo -Hu paperless /bin/sh rename.sh

### install wheels
python3.11 -m ensurepip --upgrade
sudo -Hu paperless cp paperless-ngx/requirements.txt ./
sudo -Hu paperless sed -i '' 1d requirements.txt

cp /root/install_wheels.sh ./
chown ${username}:${username} install_wheels.sh
sudo -Hu paperless /bin/sh install_wheels.sh
# pip3.11 install --no-build-isolation pyyaml==6.0.1

### adjust paperless config
cd ${home}/${appname}
sed -i '' "s|#PAPERLESS_REDIS=redis://localhost:6379|PAPERLESS_REDIS=redis://localhost:6379|" paperless.conf
sed -i '' "s|#PAPERLESS_URL=https://example.com|PAPERLESS_URL=`uname -n`.local|" paperless.conf

## folders
sed -i '' "s|#PAPERLESS_CONSUMPTION_DIR=../consume|PAPERLESS_CONSUMPTION_DIR=/mnt/consume|" paperless.conf
sed -i '' "s|#PAPERLESS_DATA_DIR=../data|PAPERLESS_DATA_DIR=/mnt/data|" paperless.conf
sed -i '' "s|#PAPERLESS_MEDIA_ROOT=../media|PAPERLESS_MEDIA_ROOT=/mnt/media|" paperless.conf

## software
# my NAS has only 2 cores so limit workers
sed -i '' "s|#PAPERLESS_TASK_WORKERS=1|PAPERLESS_TASK_WORKERS=1|" paperless.conf
sed -i '' "s|#PAPERLESS_THREADS_PER_WORKER=1|PAPERLESS_THREADS_PER_WORKER=1|" paperless.conf
# FreeBSD doesn't support inotify, so enable pulling
sed -i '' "s|#PAPERLESS_CONSUMER_POLLING=10|PAPERLESS_CONSUMER_POLLING=10|" paperless.conf
sed -i '' "s|#PAPERLESS_CONSUMER_DELETE_DUPLICATES=false|PAPERLESS_CONSUMER_DELETE_DUPLICATES=true|" paperless.conf
sed -i '' "s|#PAPERLESS_CONSUMER_RECURSIVE=false|PAPERLESS_CONSUMER_RECURSIVE=true|" paperless.conf
sed -i '' "s|#PAPERLESS_CONSUMER_IGNORE_PATTERNS=[".DS_STORE/*", "._*", ".stfolder/*", ".stversions/*", ".localized/*", "desktop.ini"]|PAPERLESS_CONSUMER_IGNORE_PATTERNS=[".DS_STORE/*", "._*", ".stfolder/*", ".stversions/*", ".localized/*", "desktop.ini"]|" paperless.conf
sed -i '' "s|#PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS=false|PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS=true|" paperless.conf

chown ${username}:${username} paperlsess.conf

# python3.11 src/manage.py migrate
# python src/manage.py createsuperuser

sysrc -f /etc/rc.conf redis_enable=YES
# echo "Enable nginx service"
sysrc -f /etc/rc.conf nginx_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_flags="-f /usr/local/etc/mdnsresponder.conf"
# sysrc -f /etc/rc.conf paperless-ngx_enable=YES
sysrc -f /etc/rc.conf paperless-ngx_env="PATH=${PATH}:${home}/.local/bin"
# service paperless-ngx start
service nginx start
service mdnsresponderposix start

echo "There is no default username and password, register new user with your credentials." >> /root/PLUGIN_INFO
