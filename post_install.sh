#!/bin/tcsh


# echo "install paperless"

# echo "Fetch and install paperless"


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

# chown -R ${username}:${username} ${home}/${appname}

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

sudo -Hu ${username} fetch https://github.com/paperless-ngx/paperless-ngx/releases/download/v2.7.2/paperless-ngx-v2.7.2.tar.xz && \
sudo -Hu ${username} tar -xf paperless-ngx-v2.7.2.tar.xz


### fetch prebuild wheels
sudo -Hu ${username} fetch https://github.com/hellvesper/iocage-plugin-paperless-ngx/releases/download/v2.7.2%4013.2-RELEASE/wheels.tar.xz
sudo -Hu ${username} tar -xf wheels.tar.xz

### rename wheels, because it python store os version from 'uname -r' which is TrueNAS base os version
cp /root/rename.sh ./
chown ${username}:${username} rename.sh
sudo -Hu ${username} /bin/sh rename.sh

### install wheels
sudo -Hu ${username} python3.11 -m ensurepip --upgrade
sudo -Hu ${username} cp ${appname}/requirements.txt ./
sudo -Hu ${username} sed -i '' 1d requirements.txt

cp /root/install_wheels.sh ./
chown ${username}:${username} install_wheels.sh
sudo -Hu ${username} /bin/sh install_wheels.sh
# pip3.11 install --no-build-isolation pyyaml==6.0.1

### adjust paperless config
cd ${home}/${appname}
sed -i '' "s|#PAPERLESS_REDIS=redis://localhost:6379|PAPERLESS_REDIS=redis://localhost:6379|" paperless.conf
sed -i '' "s|#PAPERLESS_URL=https://example.com|PAPERLESS_URL=http://`uname -n`.local|" paperless.conf

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
sed -i '' "s|#PAPERLESS_CONSUMER_IGNORE_PATTERNS=|PAPERLESS_CONSUMER_IGNORE_PATTERNS=|" paperless.conf
sed -i '' "s|#PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS=false|PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS=true|" paperless.conf

chown ${username}:${username} paperlsess.conf

sed -i '' '/<policymap>/a\
  <policy domain="coder" rights="read|write" pattern="{GIF,JPEG,PNG,WEBP,PDF}" />\
' /usr/local/etc/ImageMagick-7/policy.xml

# sed -i '' 's#<policymap>#<policymap> \
#   <policy domain="coder" rights="read|write" pattern="{GIF,JPEG,PNG,WEBP,PDF}"/>#' /usr/local/etc/ImageMagick-7/policy.xml

### by some reason you should be in src dir runnning manage.py to use config
cd ${home}/{$appname}/src
sudo -Hu ${username} python3.11 manage.py migrate

# python src/manage.py createsuperuser

# Generate a random password
setenv ADMIN_PASSWORD `openssl rand -base64 12`
echo "Generated admin password: $ADMIN_PASSWORD" > /root/PLUGIN_INFO

# Create a superuser non-interactively using the generated password
# setenv DJANGO_SUPERUSER_PASSWORD "$ADMIN_PASSWORD"
setenv PAPERLESS_ADMIN_PASSWORD "$ADMIN_PASSWORD"
# setenv DJANGO_SUPERUSER_USERNAME "admin"
# setenv DJANGO_SUPERUSER_EMAIL "admin@example.com"

sudo -Hu ${username} python3.11 manage.py manage_superuser
# sudo -Hu ${username} python3.11 manage.py createsuperuser --noinput --username "$DJANGO_SUPERUSER_USERNAME" --email "$DJANGO_SUPERUSER_EMAIL"
# unsetenv DJANGO_SUPERUSER_PASSWORD
# unsetenv DJANGO_SUPERUSER_USERNAME
# unsetenv DJANGO_SUPERUSER_EMAIL

### rc scripts ensure path
sed -i '' "s|paperless|${username}|g" /usr/local/etc/rc.d/paperless
sed -i '' "s|paperless|${username}|g" /usr/local/sbin/paperless
sed -i '' "s|/usr/home/paperless/paperless-ngx/src|/usr/${home}/${appname}/src|g" /usr/local/sbin/paperless

sed -i '' "s|paperless|${username}|g" /usr/local/etc/rc.d/paperless

### nginx config tweak
sed -i '' "s|paperless|`uname -n`|g" /usr/local/etc/nginx/sites-available/${username}.conf
ln -s /usr/local/etc/nginx/sites-available/${username}.conf /usr/local/etc/nginx/sites-enabled/${username}.conf

sysrc -f /etc/rc.conf redis_enable=YES
# echo "Enable nginx service"
sysrc -f /etc/rc.conf nginx_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_flags="-f /usr/local/etc/mdnsresponder.conf"
sysrc -f /etc/rc.conf paperless-ngx_enable=YES
sysrc -f /etc/rc.conf paperless_ngx_env="PATH=${PATH}:${home}/.local/bin"
service redist start
service paperless-ngx start
service nginx start
service mdnsresponderposix start

echo "There is no default username and password, register new user with your credentials." >> /root/PLUGIN_INFO
