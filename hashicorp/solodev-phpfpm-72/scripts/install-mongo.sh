#Install Mongo
cat <<EOF > /etc/yum.repos.d/mongodb-org-4.0.repo
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
EOF
yum install -y mongodb-org

#Mongo Config
echo 'echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time' >> /etc/rc.local
echo 'touch /var/lock/subsys/local' >> /etc/rc.local
      
#Make Mongo Node
mkdir -p /mongo
mkdir -p /mongo/data/journal /mongo/log
chown -Rf mongod:mongod /mongo
chown -Rv mongod:mongod /var/lib/mongo

chkconfig mongod on
service mongod start