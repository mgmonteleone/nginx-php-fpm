FROM ubuntu:15.10
MAINTAINER Matthew G. Monteleone

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# fix locale problem
RUN export LC_ALL=en_US.UTF-8
RUN export LANG=en_US.UTF-8

# Add sources for latest nginx
RUN apt-get update && apt-get -y dist-upgrade && apt-get update &&\
 apt-get install -y --force-yes wget software-properties-common \
 build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget build-essential zlib1g-dev unzip \
 libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev  libperl-dev libgoogle-perftools-dev \
 php5-fpm php5-mysql php-apc pwgen python-setuptools curl git unzip vim nano \
 php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap \ 
 php5-mcrypt php5-memcache php5-memcached php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl \
 ghostscript imagemagick \
 && apt-get clean && apt-get purge

## PageSpeed
RUN cd /opt
WORKDIR /opt
RUN NPS_VERSION=1.10.33.4 && \
 wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip -O release-${NPS_VERSION}-beta.zip && \
 unzip release-${NPS_VERSION}-beta.zip && \
 cd ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
 wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
 tar -xzvf ${NPS_VERSION}.tar.gz && \
 rm -f /opt/release-${NPS_VERSION}-beta.zip

##NGINX
RUN cd /opt
WORKDIR /opt
ENV NGINX_VERSION 1.9.10
ENV NPS_VERSION=1.10.33.4
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz &&tar -xvzf nginx-${NGINX_VERSION}.tar.gz && cd /opt && \
        wget https://github.com/nbs-system/naxsi/archive/0.54.tar.gz && \
        wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz&& \
	tar -xvzf ngx_cache_purge-2.3.tar.gz && \
	tar -xvzf 0.54.tar.gz && \
        cd /opt/nginx-${NGINX_VERSION}/ && \
        /opt/nginx-${NGINX_VERSION}/configure --prefix=/etc/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log \
        --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
        --http-log-path=/var/log/nginx/access.log --http-proxy-temp-path=/var/lib/nginx/proxy \
        --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
        --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-debug --with-http_addition_module\
        --add-module=/opt/ngx_pagespeed-release-${NPS_VERSION}-beta \
	 --with-http_gzip_static_module \
         --with-http_realip_module --with-http_stub_status_module --with-http_sub_module \
         --with-ipv6  \
         --add-module=/opt/naxsi-0.54/naxsi_src \
	--add-module=/opt/ngx_cache_purge-2.3 \
         --sbin-path=/usr/sbin/nginx && \
        make && make install && \
        rm -f /opt/nginx-${NGINX_VERSION} -R && \
        rm -f /opt/nginx-${NGINX_VERSION}.tar.gz && \
        rm -f /opt/ngx_cache_purge-2.3.tar.gz && \
        rm -f /opt/ngx_cache_purge-2.3 -R && \
        rm -f /opt/0.54.tar.gz && \
        rm -f /opt/naxsi-0.54 -R && \
        rm -f /opt/ngx_pagespeed-release-${NPS_VERSION}-beta -R

RUN mkdir /var/lib/nginx && chown www-data:www-data /var/lib/nginx/ -R
#RUN rm -f /etc/nginx/* -R
VOLUME [ "/data/nginx/cache", "/var/log/nginx"]
RUN mkdir -p /data/nginx/cache
RUN mkdir -p /data/ngx_pagespeed_cache
RUN chown www-data:www-data /data/nginx/cache -R
COPY timezone /etc/timezone


# tweak nginx config
RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf # gets over written by start.sh to match cpu's on container
RUN sed -i -e"s/user  nginx/user www-data/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN sed -i "s/.*conf\.d\/\*\.conf;.*/&\n    include \/etc\/nginx\/sites-enabled\/\*;/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php5/fpm/pool.d/www.conf

RUN  echo "opcache.enable_cli=1" >> "/etc/php5/fpm/conf.d/05-opcache.ini" && \
  echo "opcache.memory_consumption=128" >> "/etc/php5/fpm/conf.d/05-opcache.ini" && \
  echo "opcache.interned_strings_buffer=8" >> "/etc/php5/fpm/conf.d/05-opcache.ini" && \
  echo "opcache.max_accelerated_files=4000" >> "/etc/php5/fpm/conf.d/05-opcache.ini" && \
  echo "opcache.fast_shutdown=1" >> "/etc/php5/fpm/conf.d/05-opcache.ini"

RUN echo "env[test_val] = 'myval'" >> /etc/php5/fpm/pool.d/www.conf


# fix ownership of sock file for php-fpm as our version of nginx runs as nginx
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php5/fpm/pool.d/www.conf
RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx site conf
RUN rm -Rf /etc/nginx/conf.d/*
RUN mkdir -p /etc/nginx/sites-available/
RUN mkdir -p /etc/nginx/sites-enabled/
RUN mkdir -p /etc/nginx/ssl/
ADD ./nginx-site.conf /etc/nginx/sites-available/default.conf
ADD ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./nginx/conf.d/* /etc/nginx/conf.d/
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# add test PHP file
ADD ./index.php /usr/share/nginx/html/index.php
RUN chown -Rf www-data:www-data /usr/share/nginx/html/

# Supervisor Config
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./supervisord.conf /etc/supervisord.conf

# Start Supervisord
ADD ./setup.py /setup.py
ADD ./nginxparser.py /nginxparser.py
RUN chmod 755 /setup.py
ADD ./run.sh /start.sh
RUN chmod 755 /start.sh
RUN chown www-data:www-data /data -R
RUN mkdir /var/log/pagespeed
RUN chown www-data:www-data /var/log/pagespeed
#set up security for pagespeed stuff
ADD ./nginx/acl.conf /etc/nginx/acl.conf
ADD ./nginx/.htpasswd /etc/nginx/.htpasswd
RUN chown www-data:www-data /etc/nginx/ -R
# Expose Ports
EXPOSE 80
ENV env_prefix WP_
ENV enable_pagespeed off
RUN pip install pyparsing
CMD ["/bin/bash", "/start.sh"]
