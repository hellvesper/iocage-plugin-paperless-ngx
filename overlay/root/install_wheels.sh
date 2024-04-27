#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"

while read requirement; do
    if ! pip3.11 install --no-index --find-links ./wheels/ "$requirement"; then
    exit 1
    fi
done < requirements.txt
