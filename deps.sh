#!/bin/sh

sudo pkg install -y gcc # for skilearn fortran
sudo pkg install -y python3 python39 cmake expect gcc ghostscript10 git gnupg icc-profiles-adobe-cs4 icc-profiles-basiccolor icc-profiles-openicc ImageMagick7-nox11 leptonica liberation-fonts-ttf libxslt libxml2 lzlib mime-support pngquant poppler-utils qpdf redis rust sqlite tesseract tesseract-data unpaper zbar zlib-ng zxing-cpp openblas
### Python311
sudo pkg install -y python311 py311-sqlite3
python3.11 -m ensurepip --upgrade
#sudo pkg install py39-zbar-py
# PyYAML workaround
export PATH=/home/$(whoami)/.local/bin:$PATH
pip3.11 install wheel

# mkdir wheels

sed -i '' '/^-i/d' requirements.txt


while read requirement; do
    if ! echo "$requirement" | grep -qE "mysqlclient|psycopg2"; then
        if ! pip3.11 wheel "$requirement" --wheel-dir=./wheels; then
            echo "Error occurred while processing $requirement"
            exit 1
        fi
    fi
done < requirements.txt

# cp *.whl wheels/
tar -cJvf wheels.tar.xz wheels
