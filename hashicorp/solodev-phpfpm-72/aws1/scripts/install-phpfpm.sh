#Install Tidy
TIDY_VERSION=5.1.25
mkdir -p /usr/local/src
cd /usr/local/src
curl -q https://codeload.github.com/htacg/tidy-html5/tar.gz/$TIDY_VERSION | tar -xz
cd tidy-html5-$TIDY_VERSION/build/cmake
cmake ../.. && make install
ln -s tidybuffio.h ../../../../include/buffio.h
cd /usr/local/src
rm -rf /usr/local/src/tidy-html5-$TIDY_VERSION
yum -y install tidy

#Install PHP-FPM 7.2
yum --enablerepo=epel --disablerepo=amzn-main -y install libwebp
yum --enablerepo=remi-php72 install -y php72-php-fpm php72-php-common \
php72-php-devel php72-php-mysqli php72-php-mysqlnd php72-php-pdo_mysql \
php72-php-gd php72-php-mbstring php72-php-pear php72-php-soap php72-php-zip php72-php-tidy \
php72-php-pecl-mongodb php72-php-pecl-apcu php72-php-pecl-oauth php72-php-pecl-xdebug
scl enable php72 'php -v'
ln -s /usr/bin/php72 /usr/bin/php

#Configure PHP-FPM conf for Apache (php72-php.conf)
rm -Rf /etc/httpd/conf.d/php.conf

echo '<Files ".user.ini">' >> /etc/httpd/conf.d/php72-php.conf
echo 'Require all denied' >> /etc/httpd/conf.d/php72-php.conf
echo '</Files>' >> /etc/httpd/conf.d/php72-php.conf
echo "AddHandler .stml .php" >> /etc/httpd/conf.d/php72-php.conf
echo "AddType text/html .stml .php" >> /etc/httpd/conf.d/php72-php.conf
echo "DirectoryIndex index.stml index.php" >> /etc/httpd/conf.d/php72-php.conf
echo 'SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1' >> /etc/httpd/conf.d/php72-php.conf
echo "<FilesMatch \.(php|phar|stml)$>" >> /etc/httpd/conf.d/php72-php.conf
echo ' SetHandler "proxy:unix:/run/www.sock|fcgi://localhost"' >> /etc/httpd/conf.d/php72-php.conf
echo "</FilesMatch>" >> /etc/httpd/conf.d/php72-php.conf
echo "security.limit_extensions = .php .stml" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "listen = /run/www.sock" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "listen.owner = apache" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "listen.mode = 0660" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "chdir = /var/www/Solodev" >> /etc/opt/remi/php72/php-fpm.d/www.conf

#Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

#Install IonCube
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xzf ioncube_loaders_lin_x86-64.tar.gz
cd ioncube/
cp ioncube_loader_lin_7.2.so /opt/remi/php72/root/usr/lib64/php/modules/

#Configure php.ini
echo "short_open_tag = On" >> /etc/opt/remi/php72/php.ini
echo "expose_php = Off" >>/etc/opt/remi/php72/php.ini
echo "max_execution_time = 90" >>/etc/opt/remi/php72/php.ini
echo "max_input_time = 90" >>/etc/opt/remi/php72/php.ini
echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_STRICT & ~E_WARNING" >>/etc/opt/remi/php72/php.ini
echo "post_max_size = 60M" >>/etc/opt/remi/php72/php.ini
echo "upload_max_filesize = 60M" >>/etc/opt/remi/php72/php.ini
echo "date.timezone = UTC" >>/etc/opt/remi/php72/php.ini
echo "realpath_cache_size = 1M" >>/etc/opt/remi/php72/php.ini
echo "session.cookie_httponly = 1" >>/etc/opt/remi/php72/php.ini
echo "[apcu]" >>/etc/opt/remi/php72/php.ini
echo "apc.enabled=1" >>/etc/opt/remi/php72/php.ini
echo "apc.shm_size=32M" >>/etc/opt/remi/php72/php.ini
echo "apc.ttl=7200" >>/etc/opt/remi/php72/php.ini
echo "apc.enable_cli=0" >>/etc/opt/remi/php72/php.ini
echo "apc.serializer=php" >>/etc/opt/remi/php72/php.ini
echo "apc.stat=0" >>/etc/opt/remi/php72/php.ini
echo "[custom]" >>/etc/opt/remi/php72/php.ini
echo "realpath_cache_ttl = 7200" >>/etc/opt/remi/php72/php.ini
echo "realpath_cache_size = 4096k" >>/etc/opt/remi/php72/php.ini
echo "opcache.enable=1" >>/etc/opt/remi/php72/php.ini
echo "opcache.memory_consumption=128" >>/etc/opt/remi/php72/php.ini
echo "opcache.max_accelerated_files=4000" >>/etc/opt/remi/php72/php.ini
echo "opcache_revalidate_freq = 240" >>/etc/opt/remi/php72/php.ini
echo "zend_extension=/opt/remi/php72/root/usr/lib64/php/modules/ioncube_loader_lin_7.2.so" >>/etc/opt/remi/php72/php.ini

#Start
chkconfig php72-php-fpm on