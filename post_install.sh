#!/bin/tcsh


echo "install paperless"

echo "Fetch and install paperless"
cd /root && fetch https://github.com/hellvesper/iocage-plugin-paperless-ngx/releases/download/paperless-ngx-10.4.0/paperless-ngx-latest.tar.gz && \
tar -xf paperless-ngx-latest.tar.gz && \
mv paperless-ngx-latest paperless-ngx && \
/root/paperless-ngx/bin/server.sh install

# Define the username and other details
# set username="paperless-ngx"
# set fullname="paperless-ngx"
# set uid=1001
# set gid=1001
# set home="/home/paperless-ngx"
# set shell="/bin/bash"

# Create group
# /usr/sbin/pw groupadd ${username}

# Create the user
# /usr/sbin/pw useradd ${username} -n ${fullname} -u ${uid} -g ${gid} -m -s ${shell}

# Set a password for the new user
#echo "newuser:password" | /usr/sbin/chpass

# Optionally, add the user to a group
#/usr/sbin/pw groupmod staff -m ${username}

# cp /root/paperless-ngx /home/paperless-ngx/
# chown paperless-ngx:paperless-ngx /home/paperless-ngx
pip install --no-build-isolation pyyaml==6.0
# echo "Enable nginx service"
sysrc -f /etc/rc.conf nginx_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_flags="-f /usr/local/etc/mdnsresponder.conf"
sysrc -f /etc/rc.conf paperless-ngx_enable=YES
sysrc -f /etc/rc.conf paperless-ngx_env="PATH=${PATH}:/usr/local/bin:/usr/local/sbin"
service paperless-ngx start
service nginx start
service mdnsresponderposix start

echo "There is no default username and password, register new user with your credentials." >> /root/PLUGIN_INFO
