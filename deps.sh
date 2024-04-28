#!/bin/sh

sudo pkg install -y gcc # for skilearn fortran
sudo pkg install -y python3 python39 cmake expect gcc ghostscript10 git gnupg icc-profiles-adobe-cs4 icc-profiles-basiccolor icc-profiles-openicc ImageMagick7-nox11 leptonica liberation-fonts-ttf libxslt libxml2 lzlib mime-support pngquant poppler-utils qpdf redis rust sqlite tesseract tesseract-data unpaper zbar zlib-ng zxing-cpp openblas
### Python311
sudo pkg install python311 py311-sqlite3
#sudo pkg install py39-zbar-py
# PyYAML workaround
pip install wheel
#pip install "cython<3.0.0"
pip wheel --no-build-isolation pyyaml==6.0.1
# scipy fix
#pip install pythran>=0.13.1
export PATH=/home/vesper/.local/bin:$PATH
while read requirement; do
    if ! pip wheel "$requirement" --wheel-dir=./; then
        echo "Error occurred while processing $requirement"
        exit 1
    fi
done < requirements.txt

mkdir wheels
cp *.whl wheels/
tar -cJvf wheels.tar.xz wheels
