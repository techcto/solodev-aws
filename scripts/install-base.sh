#Install Package Repos (REMI, EPEL)
yum -y remove php* httpd*
yum install -y yum-utils
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh epel-release-latest-7.noarch.rpm
rpm -Uvh remi-release-7.rpm
yum update -y

#Install Required Devtools
yum -y install gcc-c++ gcc pcre-devel make zip wget curl cmake git ruby

#Install AWS CodeDeploy Agent
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent start
chkconfig codedeploy-agent on

# Add Swap
/bin/dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048 &
wait $!
chown root:root /mnt/swapfile
chmod 600 /mnt/swapfile
/sbin/mkswap /mnt/swapfile
/sbin/swapon /mnt/swapfile