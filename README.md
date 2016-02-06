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

### NGINX and fastcgi caching

The included nginx-site.conf file is copied to the container as running site config and has customiztions for 
PHP caching.

- Does not cache posts.
- Does not cache a variety of special locations and files for Wordpress.

What we dont cache....

    # Don't cache uris containing the following segments
	if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
		set $skip_cache 1;
	}   

	# Don't use the cache for logged in users or recent commenters
	if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
		set $skip_cache 1;
	}

- Some special handeling of static files.

Config fragment....

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|woff|eot|ttf)$ {
                access_log        off;
                log_not_found     off;
                expires           5d;
		add_header Access-Control-Allow-Origin "*";
        }

#### Caching fast-cgi cache

In order to purge the fast-cgi cache we just need to go a get to the `/purge/` end point with the **FULL** URL to be 
purged.

    location ~ /purge(/.*) {
	    fastcgi_cache_purge WORDPRESS "$scheme$request_method$host$1";
	}

## PageSpeed
Includes the latest Google pagespeed module for dynamic speed up, caching and optimization.
Has some sane defaults built in (ok, semi sane), which are targeted to Wordpress Installations.

![Pagespeed](https://camo.githubusercontent.com/4138679c6cf85adb18c4cf820189c898f7dbf5cb/68747470733a2f2f6c68362e676f6f676c6575736572636f6e74656e742e636f6d2f2d71756665644a494a7137592f55584576565978795976492f4141414141414141446f382f4a48444651687339315f632f733430312f30345f6e67785f7061676573706565642e706e67 "Google")

- Current Pagespeed version : **1.10.33.4**

Pagespeed is disabled by default, and is turned on by setting an environment variable `enable_pagespeed` to "on".

like this:
   
    docker run ...
    -e enable_pagespeed on
    ...


[Nginx Pagespeed Documentation](https://developers.google.com/speed/pagespeed/module/configuration)

## Nginx Cache purge
Includes on demand php-fpm cache purging from [Frickle Labs](http://labs.frickle.com/nginx_ngx_cache_purge/)

