#!/bin/sh

while read requirement; do
    if ! pip install --no-index --find-links ./wheels-temp/ "$requirement"; then
    exit 1
    fi
done < requirements.txt
