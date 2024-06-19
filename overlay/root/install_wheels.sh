#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"

pip3.11 install --user python-dotenv==1.0.1 whitenoise==6.6.0
while read requirement; do
    if [ "$requirement" = "mysqlclient" ]; then
        echo "Skipping installation of mysqlclient"
        continue
    fi
    if ! pip3.11 install --user --no-warn-script-location --no-index --find-links ./wheels/ "$requirement"; then
    exit 1
    fi
done < requirements.txt
pip3.11 install --user --no-warn-script-location --force-reinstall pillow