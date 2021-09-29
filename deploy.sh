#!/bin/sh
USER=root
HOST=120.27.38.195
DIR=/var/www/html/hugo_blog

rsync -avz --delete public/ ${USER}@${HOST}:${DIR}

exit 0
