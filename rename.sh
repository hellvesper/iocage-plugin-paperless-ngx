#!/bin/sh

for file in *freebsd_13_2_release*.whl; do
    mv "$file" "$(echo "$file" | sed 's/13_2_release/13_1_release_p9/')"
done

for file in *freebsd_13_2_RELEASE*.whl; do
    mv "$file" "$(echo "$file" | sed 's/13_2_RELEASE/13_1_release_p9/')"
done
