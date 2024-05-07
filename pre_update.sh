#!/usr/local/bin/zsh

echo $SHELL

service paperless stop
# Check if the paperless service has stopped and wait until it has stopped
while [[ "$(service paperless status | grep 'is running')" != "" ]]
do
    echo "Waiting for paperless service to stop..."
    sleep 1
done
echo "Paperless service stopped."
echo ""

sysrc -f /etc/rc.conf paperless_enable=NO

service redis stop

# Check if the redis service has stopped and wait until it has stopped
while [[ "$(service redis status | grep 'is running')" != "" ]]
do
    echo "Waiting for redis service to stop..."
    sleep 1
done
echo "Redis service stopped."
echo ""

# Check if any Python application is running and kill all instances
echo "Checking for running Python applications..."
for pid in $(pgrep -f python)
do
    kill -9 $pid
done
echo "All running Python applications have been terminated."
echo ""

# Remove paperless-ngx tarball with any version number if it exists
echo "Checking for existing paperless-ngx tarballs to remove..."
for file in $(find /home/paperless -type f -name 'paperless-ngx-*.tar.xz')
do
    echo "Removing $file"
    rm $file
done
echo "Removal of paperless-ngx tarballs complete."
echo ""

echo "Creating backup of the paperless-ngx folder..."
tar -czf /home/paperless/paperless-ngx.tar.gz /home/paperless/paperless-ngx
mv /home/paperless/paperless-ngx.tar.gz /home/paperless/paperless-ngx.tar.gz.bak
echo "Backup created and renamed to paperless-ngx.tar.gz.bak."
echo ""

echo "Backing up paperless.conf to user home directory..."
cp /home/paperless/paperless-ngx/paperless.conf /home/paperless/paperless.conf
echo "Backup of paperless.conf completed."
echo ""

echo "Removing the original paperless-ngx folder..."
rm -rf /home/paperless/paperless-ngx
echo "Original paperless-ngx folder removed."
echo ""
