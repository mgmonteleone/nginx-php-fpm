#!/bin/bash

# Tweak nginx to match the workers to cpu's

procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Run the setup script to take care of environment variables and app name
python /setup.py --env_prefix=WP_


# Start supervisord and services
/usr/local/bin/supervisord -n
