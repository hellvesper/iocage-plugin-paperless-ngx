#!/bin/tcsh

service paperless stop
# Check if the paperless service has stopped and wait until it has stopped
while (`service paperless status | grep -q 'is running'`)
    echo "Waiting for paperless service to stop..."
    sleep 1
end
echo "Paperless service stopped."

sysrc -f /etc/rc.conf paperless_enable=NO

service redis stop

# Check if the redis service has stopped and wait until it has stopped
while (`service redis status | grep -q 'is running'`)
    echo "Waiting for redis service to stop..."
    sleep 1
end
echo "Redis service stopped."

# Check if any Python application is running and kill all instances
echo "Checking for running Python applications..."
foreach pid (`pgrep -f python`)
    kill -9 $pid
end
echo "All running Python applications have been terminated."

# Remove paperless-ngx tarball with any version number if it exists
echo "Checking for existing paperless-ngx tarballs to remove..."
foreach file (`find /home/paperless -type f -name 'paperless-ngx-*.tar.xz'`)
    echo "Removing $file"
    rm $file
end
echo "Removal of paperless-ngx tarballs complete."

echo "Creating backup of the paperless-ngx folder..."
tar -czf /home/paperless/paperless-ngx.tar.gz /home/paperless/paperless-ngx
mv /home/paperless/paperless-ngx.tar.gz /home/paperless/paperless-ngx.tar.gz.bak
echo "Backup created and renamed to paperless-ngx.tar.gz.bak."

echo "Backing up paperless.conf to user home directory..."
cp /home/paperless/paperless-ngx/paperless.conf /home/paperless/paperless.conf
echo "Backup of paperless.conf completed."

echo "Removing the original paperless-ngx folder..."
rm -rf /home/paperless/paperless-ngx
echo "Original paperless-ngx folder removed."
