#!/bin/tcsh

service paperless stop
# Check if the paperless service has stopped and wait until it has stopped
while service paperless status | grep -q 'is running'; do
    echo "Waiting for paperless service to stop..."
    sleep 1
done
echo "Paperless service stopped."

sysrc -f /etc/rc.conf paperless_enable=NO

service redis stop

# Check if the redis service has stopped and wait until it has stopped
while service redis status | grep -q 'is running'; do
    echo "Waiting for redis service to stop..."
    sleep 1
done
echo "Redis service stopped."

# Check if any Python application is running and kill all instances
echo "Checking for running Python applications..."
pgrep -f python | xargs -r kill -9
echo "All running Python applications have been terminated."

# Remove paperless-ngx tarball with any version number if it exists
echo "Checking for existing paperless-ngx tarballs to remove..."
find /home/paperless -type f -name 'paperless-ngx-*.tar.xz' -exec echo "Removing {}" \; -exec rm {} \;
echo "Removal of paperless-ngx tarballs complete."

echo "Creating backup of the paperless-ngx folder..."
tar -czf /home/paperless/paperless-ngx.tar.gz /home/paperless/paperless-ngx
mv /home/paperless/paperless-ngx.tar.gz /home/paperless/paperless-ngx.tar.gz.bak
echo "Backup created and renamed to paperless-ngx.tar.gz.bak."

echo "Removing the original paperless-ngx folder..."
rm -rf /home/paperless/paperless-ngx
echo "Original paperless-ngx folder removed."
