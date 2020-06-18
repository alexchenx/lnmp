#!/bin/bash
# Description: Install PHP7.3.5

yum install -y wget gcc gcc-c++ libxml2 libxml2-devel autoconf openssl openssl-devel libpng libpng-devel
mkdir -p /data/{software,app}

php_home="/data/app/php"

cd /data/software/

if [ -f /data/software/php-7.3.19.tar.gz ]; then
        echo "/data/software/php-7.3.19.tar.gz is exist, delete it."
        rm -rf /data/software/php-7.3.19.tar.gz
fi
if [ -d /data/software/php-7.3.19 ]; then
        echo "/data/software/php-7.3.19 is exist, delete it."
        rm -rf /data/software/php-7.3.19
fi
if [ -d /data/app/php ]; then
        echo "/data/app/php is exist, delete it."
        rm -rf /data/app/php
fi


# Install curl
wget https://curl.haxx.se/download/curl-7.70.0.tar.gz
tar -zxvf curl-7.70.0.tar.gz
cd curl-7.70.0.tar.gz
./configure --prefix=/data/app/curl
make && make install

if [ $? != 0 ]; then
	echo "curl install failed."
	exist
fi


# Install php
id www
if [ $? != 0 ]; then
	useradd www
fi
wget https://www.php.net/distributions/php-7.3.19.tar.gz
tar -zxvf php-7.3.19.tar.gz
cd php-7.3.19
./configure --prefix=${php_home} --enable-fpm --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib --with-openssl --with-gd --with-curl=/data/app/curl
make && make install
cp ${php_home}/etc/php-fpm.conf.default ${php_home}/etc/php-fpm.conf 
cp ${php_home}/etc/php-fpm.d/www.conf.default ${php_home}/etc/php-fpm.d/www.conf
cp /data/software/php-7.3.5/php.ini-production ${php_home}/lib/php.ini
sed -i 's/user = nobody/user = www/' ${php_home}/etc/php-fpm.d/www.conf
sed -i 's/group = nobody/group = www/' ${php_home}/etc/php-fpm.d/www.conf

echo "Config envionment variables."
echo "export PATH=\$PATH:${php_home}/bin/" >> /etc/profile
source /etc/profile

echo "Set start when boot server."
echo "${php_home}/sbin/php-fpm" >> /etc/rc.local
chmod +x /etc/rc.local

echo "Start php-fpm"
pkill php-fpm
${php_home}/sbin/php-fpm

echo "Done."
