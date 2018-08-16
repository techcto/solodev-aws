template 'mongod.conf' do
  path "/etc/mongod.conf"
  source 'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

script "mongo_brick" do
	not_if { ::File.exists?("/mongo/data/journal") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
		
    echo 'echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time' >> /etc/rc.local
    echo 'touch /var/lock/subsys/local' >> /etc/rc.local
    
    #Make Mongo Node
    mkfs.ext4 /dev/sdm
    mkdir -p /mongo
    echo '/dev/sdm /mongo ext4 defaults,auto,noexec 0 0' >> /etc/fstab
    mount -a
    mkdir -p /mongo/data/journal /mongo/log
    blockdev --setra 32 /dev/sdm
    chown -Rf mongod:mongod /mongo
    chown -Rv mongod:mongod /var/lib/mongo

    chkconfig mongod on
		service mongod start
		service mongod status


	EOH
end

script "mongo_service" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
		
    chkconfig mongod on
		service mongod start
		service mongod status

	EOH
end