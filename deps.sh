#!/bin/sh

sudo pkg install -y gcc # for skilearn fortran
sudo pkg install py39-zbar-py
# PyYAML workaround
pip install wheel
pip install "cython<3.0.0"
pip install --no-build-isolation pyyaml==6.0
# scipy fix
pip install pythran>=0.13.1
export PATH=/home/vesper/.local/bin:$PATH
while read requirement; do
    if ! pip wheel "$requirement" --wheel-dir=/path/to/wheelhouse; then
        echo "Error occurred while processing $requirement"
        exit 1
    fi
done < requirements.txt

for whl in /path/to/wheelhouse/*.whl; do
    pip install "$whl"
done

while read requirement; do
    pip install --no-index --find-links ../wheels/ "$requirement"
done < requirements.txt

for file in *freebsd_13_2_release*.whl; do
    mv "$file" "${file//13_2_release/13_1_release_p9}"
done
# Fix bad substitution error in shell script
for file in *freebsd_13_2_release*.whl; do
    mv "$file" "$(echo "$file" | sed 's/13_2_release/13_1_release_p9/')"
done
