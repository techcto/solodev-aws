#Install Mysql
yum -y install mariadb-server mariadb
chkconfig mariadb on
service mariadb start