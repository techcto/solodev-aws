#Install Apache 2.4
yum install -y httpd
sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/g' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/g' /etc/httpd/conf.modules.d/00-mpm.conf
chkconfig httpd on
service httpd start

#Install SSL
yum -y install openssl-devel mod_ssl
sed -i 's/SSLProtocol all -SSLv2$/SSLProtocol all -SSLv2 -SSLv3/g' /etc/httpd/conf.d/ssl.conf

#Permissions
usermod -a -G apache ec2-user