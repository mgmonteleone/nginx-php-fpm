## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm.
Uses some base configs which are stored in this repo.
- Automatically pull source from the respective sites
- The version of nginx and pagespeed are set using env variables, found near the top of the Dockerfile. 

Dockerfile settings

    ENV NGINX_VERSION 1.9.10
    ENV NPS_VERSION 1.10.33.4


## Base
![Ubuntu](http://design.ubuntu.com/wp-content/uploads/ubuntu-logo112.png "Ubuntu")

Container is based on Ubuntu 15.10

## PHP and PHP-FPM

- PHP Version: **5.6.11**

- Runs last PHP 5.x version from Ubuntu repositories.
- If nothing is mounted to the content directory, a PHP test file will be used as the default root.


## Nginx Versions
![Nginx](https://assets.wp.nginx.com/wp-content/uploads/2015/04/NGINX_logo_rgb-01.png "Nginx")

- Mainline Version: **1.9.10**

## PageSpeed
Includes the latest Google pagespeed module for dynamic speed up, caching and optimization.
Has some sane defaults built in (ok, semi sane), which are targeted to Wordpress Installations.

![Pagespeed](https://blog.keycdn.com/blog/wp-content/uploads/2015/09/google-pagespeed-insights.png "Google")

- Current Pagespeed version : **1.10.33.4**

Pagespeed is disabled by default, and is turned on by setting an environment variable `enable_pagespeed` to "on".

like this:
   
    docker run ...
    -e enable_pagespeed on
    ...


[Nginx Pagespeed Documentation](https://developers.google.com/speed/pagespeed/module/configuration)

## Nginx Cache purge
Includes on demand php-fpm cache purging from [Frickle Labs](http://labs.frickle.com/nginx_ngx_cache_purge/)

