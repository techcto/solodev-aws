#Install Mongo
cat <<EOF > /etc/yum.repos.d/10gen.repo
[10gen]
name=10gen Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64
gpgcheck=0
enabled=1
EOF
yum install mongo-10gen mongo-10gen-server mongodb-org-shell -y

#Mongo Config
echo 'echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time' >> /etc/rc.local
echo 'touch /var/lock/subsys/local' >> /etc/rc.local
      
#Make Mongo Node
mkdir -p /mongo
mkdir -p /mongo/data/journal /mongo/log
chown -Rf mongod:mongod /mongo
chown -Rv mongod:mongod /var/lib/mongo

chkconfig mongod on