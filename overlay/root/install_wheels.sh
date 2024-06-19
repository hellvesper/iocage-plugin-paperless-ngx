#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"

pip3.11 install --user python-dotenv
while read requirement; do
    if ! pip3.11 install --user --no-warn-script-location --no-index --find-links ./wheels/ "$requirement"; then
    exit 1
    fi
done < requirements.txt
pip3.11 install --user --no-warn-script-location --force-reinstall pillow