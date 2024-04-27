## Packages

### Base
pkg install python3 python39 cmake expect gcc ghostscript10 git gnupg icc-profiles-adobe-cs4 icc-profiles-basiccolor icc-profiles-openicc ImageMagick7-nox11 leptonica liberation-fonts-ttf libxslt libxml2 lzlib mime-support pngquant poppler-utils qpdf redis rust sqlite tesseract tesseract-data unpaper zbar zlib-ng zxing-cpp openblas

### Python39
pkg install py39-backports.zoneinfo py39-bleach py39-brotli py39-celery py39-certifi py39-charset-normalizer py39-coloredlogs py39-dateutil py39-dj42-django-cors-headers py39-dj42-djangorestframework py39-django42  py39-filelock py39-gunicorn py39-hiredis py39-httpcore py39-httptools py39-httpx py39-humanfriendly py39-idna py39-importlib-resources py39-langdetect py39-msgpack py39-nltk py39-ocrmypdf py39-pdfminer.six py39-pikepdf py39-pip py39-pipenv py39-prometheus-client py39-prompt-toolkit py39-psycopg2 py39-pyinotify py39-python-dotenv py39-python-gnupg py39-python-magic py39-pytz py39-rapidfuzz py39-redis py39-scikit-learn py39-scipy py39-setproctitle py39-setuptools_scm py39-sqlite3 py39-sqlparse py39-tornado py39-tqdm py39-tzdata py39-uvicorn py39-uvloop py39-watchdog py39-websockets py39-whitenoise py39-whoosh py39-zstandard

### Python311
pkg install python311 py311-sqlite3

### Home
pw groupadd paperless
pw useradd paperless -g paperless -s /bin/sh
mkdir -p /usr/home/paperless
chown -R paperless:paperless /usr/home/paperless
ln -sf /usr/home /home
install -g paperless -o paperless -d /usr/home/paperless/media
install -g paperless -o paperless -d /usr/home/paperless/data
install -g paperless -o paperless -d /usr/home/paperless/consume
install -g paperless -o paperless -d /usr/home/paperless/static
install -g paperless -o paperless -d /usr/home/paperless/trash

## ImageMagick
sed -i "" -e '/PDF/s/rights="none"/rights="read|write"/' /usr/local/etc/ImageMagick-7/policy.xml

## Redis
service redis enable
service redis start

## Paperless

### Fetch & Extract
fetch https://github.com/paperless-ngx/paperless-ngx/releases/download/v1.17.4/paperless-ngx-v1.17.4.tar.xz
tar -xvzf paperless-ngx-v1.17.4.tar.xz 
mv paperless-ngx /usr/home/paperless
cd /usr/home/paperless/paperless-ngx 

### Config
ee paperless.conf

PAPERLESS_REDIS=redis://localhost:6379
PAPERLESS_DBENGINE=sqlite
PAPERLESS_CONSUMPTION_DIR=/usr/home/paperless/consume
PAPERLESS_DATA_DIR=/usr/home/paperless/data
PAPERLESS_TRASH_DIR=/usr/home/paperless/trash
PAPERLESS_MEDIA_ROOT=/usr/home/paperless/media
PAPERLESS_SECRET_KEY=Xyfd4Frfdfg4GFdo0Z0ny5c3
PAPERLESS_OCR_LANGUAGE=deu
PAPERLESS_CONVERT_BINARY=/usr/local/bin/convert
PAPERLESS_GS_BINARY=/usr/local/bin/gs
PAPERLESS_TIME_ZONE=Europe/Berlin

### Packages 2

su - paperless

pip install anyio asgiref==3.7.2 channels channels-redis click click-didyoumean click-plugins click-repl concurrent-log-handler dateparser  django-celery-results django-compression-middleware django-filter django-extensions django-guardian djangorestframework-guardian flower imap-tools inotifyrecursive pathvalidate pdf2image python-ipware pyzbar tika-client 

### First Start

#### Setup
cd /usr/home/paperless/paperless-ngx/src
/usr/local/bin/python3 manage.py migrate
/usr/local/bin/python3 manage.py createsuperuser
/usr/local/bin/python3 manage.py runserver

#### Start Services 
/usr/local/bin/python3 manage.py runserver 0.0.0.0:8000
/usr/local/bin/python3 manage.py document_consumer
/usr/local/bin/celery --app paperless worker --loglevel INFO
/usr/local/bin/celery --app paperless beat --loglevel INFO