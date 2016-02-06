## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm.
Uses some base configs which are stored in this repo.



## Nginx Versions
![Nginx](https://assets.wp.nginx.com/wp-content/uploads/2015/04/NGINX_logo_rgb-01.png "Nginx")

- Mainline Version: **1.9.10**

## PageSpeed
Includes the latest Google pagespeed module for dynamic speed up, caching and optimization.
Has some sane defaults built in (ok, semi sane), which are targeted to Wordpress Installations.

![Pagespeed](https://blog.keycdn.com/blog/wp-content/uploads/2015/09/google-pagespeed-insights.png "Google")


[Nginx Pagespeed Documentation](https://developers.google.com/speed/pagespeed/module/configuration)

## Nginx Cache purge
Includes on demand php-fpm cache purging from [Frickle Labs](http://labs.frickle.com/nginx_ngx_cache_purge/)

