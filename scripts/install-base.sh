#Install Package Repos (REMI, EPEL)
yum -y remove php* httpd*
yum install -y yum-utils
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh epel-release-latest-7.noarch.rpm
rpm -Uvh remi-release-7.rpm
yum update -y

#Install Required Devtools
wget http://195.220.108.108/linux/epel/6/x86_64/Packages/s/scl-utils-20120229-1.el6.x86_64.rpm
rpm -Uvh scl-utils-20120229-1.el6.x86_64.rpm
yum -y install gcc-c++ gcc pcre-devel make zip unzip wget curl cmake git

#Install AWS CodeDeploy Agent
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent start
chkconfig codedeploy-agent on