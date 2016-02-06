#!/usr/bin/env bash
# You can set the environment variable (with -e) to change the prefix the system uses to filter which environment
# variables will be available to php-fpm. The default image has the equivalent baked in:
# -e env_prefix WP_
#
# Environment variable "app_name" is automatically set to the folder name this container is running in, but can be
# set manually if desired, this will show in the process list for easier debugging of what php app is using resources.
#
# PHP-FPM cache is in the container at /data/nginx/cache, if you would like to be able to manually clear this cache
# from outside the container, you can mount that directory to the host.
# -v /host/directory:/data/nginx/cache
#
# Pagespeed - disabled by default, use environment variable enable_pagespeed to enable.
# -e enable_pagespeed [off/on]


port=812
name=${PWD##*/}
docker stop $name
docker rm $name
toilet -f term -F border --gay "Starting "$name
docker run -d --name $name \
-v /web/$name:/usr/share/nginx/html \
-v /logs/$name:/var/log/nginx \
-p $port:80  \
-e app_name = $name \
-e "SERVICE_TAGS=wordpress" eu.gcr.io/carbide-ratio-704/$name
