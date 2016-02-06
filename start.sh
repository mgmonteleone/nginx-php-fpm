port=812
name=${PWD##*/}
docker stop $name
docker rm $name
toilet -f term -F border --gay "Starting "$name
docker run -d --name $name \
-v /web/$name:/usr/share/nginx/html \
-v /logs/$name:/var/log/nginx \
-p $port:80  \
-e "SERVICE_TAGS=wordpress" eu.gcr.io/carbide-ratio-704/$name
