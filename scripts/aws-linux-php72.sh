#Install Package Repos (REMI, EPEL)
yum -y remove php* httpd*
yum install -y yum-utils
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh epel-release-latest-7.noarch.rpm
rpm -Uvh remi-release-7.rpm
yum update -y

#Install Required Devtools
yum -y install gcc-c++ gcc pcre-devel make zip unzip wget curl cmake git ruby

#Install AWS CodeDeploy Agent
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent start
chkconfig codedeploy-agent on

#Install Apache 2.4
yum install -y httpd
sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/g' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/g' /etc/httpd/conf.modules.d/00-mpm.conf
service httpd start
chkconfig httpd on

#Install SSL
yum -y install openssl-devel mod_ssl
sed -i 's/SSLProtocol all -SSLv2$/SSLProtocol all -SSLv2 -SSLv3/g' /etc/httpd/conf.d/ssl.conf

#Install PHP-FPM 7.2
yum-config-manager --enable remi-php72
yum --enablerepo=epel --disablerepo=amzn-main -y install libwebp
yum --enablerepo=remi-php72 install -y php72-php-fpm php72-php-common \
php72-php-devel php72-php-mysqli php72-php-mysqlnd php72-php-pdo_mysql \
php72-php-gd php72-php-mbstring php72-php-pear php72-php-soap php72-php-zip php72-php-tidy \
php72-php-pecl-mongodb php72-php-pecl-apcu php72-php-pecl-oauth php72-php-pecl-xdebug
scl enable php72 'php -v'
ln -s /usr/bin/php72 /usr/bin/php
service php72-php-fpm start
chkconfig php72-php-fpm on

#Configure PHP-FPM conf for Apache (php72-php.conf)
rm -Rf /etc/httpd/conf.d/php.conf
mkdir -p /run/php-fpm
echo '<Files ".user.ini">' >> /etc/httpd/conf.d/php72-php.conf
echo 'Require all denied' >> /etc/httpd/conf.d/php72-php.conf
echo '</Files>' >> /etc/httpd/conf.d/php72-php.conf
echo "AddHandler .stml .php" >> /etc/httpd/conf.d/php72-php.conf
echo "AddType text/html .stml .php" >> /etc/httpd/conf.d/php72-php.conf
echo "DirectoryIndex index.stml index.php" >> /etc/httpd/conf.d/php72-php.conf
echo 'SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1' >> /etc/httpd/conf.d/php72-php.conf
echo "<FilesMatch \.(php|phar|stml)$>" >> /etc/httpd/conf.d/php72-php.conf
echo ' SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"' >> /etc/httpd/conf.d/php72-php.conf
echo "</FilesMatch>" >> /etc/httpd/conf.d/php72-php.conf
echo "security.limit_extensions = .php .stml" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "listen = /run/php-fpm/www.sock" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "listen.owner = apache" >> /etc/opt/remi/php72/php-fpm.d/www.conf
echo "listen.mode = 0660" >> //etc/opt/remi/php72/php-fpm.d/www.conf

#Install Node
mkdir -p /var/www/.npm
echo 'export NODE_PATH=/var/www/.npm-global/lib/node_modules' >> /var/www/.npmrc
echo 'export PATH=$PATH:/var/www/.npm-global/bin' >> /var/www/.npmrc
export PATH=/var/www/.npm-global/bin:$PATH
curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -
yum install -y --enablerepo=nodesource nodejs
npm install -g autoprefixer clean-css-cli nodemon npm-run-all postcss-cli postcss-discard-empty shx uglify-js
npm install -g -f --unsafe-perm node-sass
npm config set prefix '/var/www/.npm-global'
chmod 2770 /var/www/.npmrc
chown apache.apache /var/www/.npmrc
chmod -Rf 2770 /var/www/.npm
chown -Rf apache.apache /var/www/.npm
chmod -Rf 2770 /var/www/.npm-global
chown -Rf apache.apache /var/www/.npm-global

#Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

#Install Tidy
TIDY_VERSION=5.1.25
RUN mkdir -p /usr/local/src
cd /usr/local/src
curl -q https://codeload.github.com/htacg/tidy-html5/tar.gz/$TIDY_VERSION | tar -xz
cd tidy-html5-$TIDY_VERSION/build/cmake
cmake ../.. && make install
ln -s tidybuffio.h ../../../../include/buffio.h
cd /usr/local/src
rm -rf /usr/local/src/tidy-html5-$TIDY_VERSION
yum -y install tidy

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

###### Solodev Install Script

tee /tmp/solodev.sh <<EOF

#Install Solodev
mkdir -p /home/ec2-user/Solodev
fn="$(aws s3 ls s3://solodev-bamboo | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://solodev-bamboo/$fn /home/ec2-user/Solodev/Solodev.zip
cd /home/ec2-user/Solodev/
unzip Solodev.zip
rm -Rf Solodev.zip
cd /home/ec2-user/
chown -Rf apache.apache Solodev
chmod -Rf 2770 Solodev
mv Solodev /var/www/

EOF

#Install Cloud Init script
tee /etc/cloud/cloud.cfg.d/install.cfg <<EOF
#install-config
runcmd:
 - /tmp/solodev.sh
EOF


#Cleanup
usermod -a -G apache wheel
rm -Rf /root/.ssh
rm -Rf /home/ec2-user/.ssh