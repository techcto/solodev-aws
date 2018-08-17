#Install Apache 2.4
yum --enablerepo=epel,remi install -y httpd24
sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_module/g' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/g' /etc/httpd/conf.modules.d/00-mpm.conf
service httpd start
chkconfig httpd on

#Install SSL
yum -y install openssl-devel mod24_ssl
sed -i 's/SSLProtocol all -SSLv2$/SSLProtocol all -SSLv2 -SSLv3/g' /etc/httpd/conf.d/ssl.conf

#Permissions
usermod -a -G apache ec2-user