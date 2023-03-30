#!/bin/sh
#
# check if docker is running
echo
echo "Verifying docker daemon..."
if ! (docker ps >/dev/null 2>&1)
then
        echo "Failed - docker daemon not running, will exit here!"
        exit
fi
echo "** Success - docker is running!"
echo
echo "Preparing folder init and creating ./init/initdb.sql"
mkdir ./init >/dev/null 2>&1
mkdir -p ./nginx/ssl >/dev/null 2>&1
chmod -R +x ./init
docker run --rm guacamole-client:1.3.0 /opt/guacamole/bin/initdb.sh --postgres > ./init/initdb.sql
echo "** complete"
echo
echo "Creating SSL cert"
openssl req -nodes -newkey rsa:2048 -new -x509 -keyout nginx/ssl/self-ssl.key -out nginx/ssl/self.cert -config ./ssl.conf
echo "** complete*"
echo
echo "You can use your own certificates by placing the private key in nginx/ssl/self-ssl.key and the cert in nginx/ssl/self.cert"
echo
echo "** done **"
