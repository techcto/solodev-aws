#Chef::Log.info(node[:database][:host])
#yml_string = YAML::dump(node[:apache].to_hash)
#Chef::Log.info(yml_string)

VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
StorageWaitHandle = node[:install][:StorageWaitHandle]

template 'limits.conf' do
  path "/etc/security/limits.conf"
  source 'limits.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template '90-nproc.conf' do
  path "/etc/security/limits.d/90-nproc.conf"
  source '90-nproc.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template 'mongod.conf' do
  path "/etc/mongod.conf"
  source 'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

#Install Software
script "install_gluster" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
		#Set timezone - TODO make this option to pass in
    perl -pi -e 's|ZONE=\"UTC\"|ZONE=\"America/New_York\"|g' /etc/sysconfig/clock
		ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
		
    #Make Gluster Brick
    chkconfig glusterd on
		service glusterd start
    mkfs.ext4 -m 1 -L gluster /dev/sdb
    mkdir -p /bricks/#{VolumeName}/
    echo '/dev/sdb /bricks/#{VolumeName} ext4 defaults 1 2' >> /etc/fstab
    mount -a
    rm -Rf /bricks/#{VolumeName}/*
    perl -pi -e "s/LOG_LEVEL=''/LOG_LEVEL='ERROR'/g" /etc/init.d/glusterd
    
    setfattr -x trusted.glusterfs.volume-id /bricks/#{VolumeName}
		setfattr -x trusted.gfid /bricks/#{VolumeName}
		#volume set #{VolumeName} nfs.disable 
    
    chkconfig ntpd on
		service ntpd start
    
    #Mongo Config & Init
    # TODO: Why is mongo running - Need to edit AMI
    service mongod status
    mongo --eval "db.getSiblingDB('admin').shutdownServer()"
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

        
		# Add Swap
  	/bin/dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
		chown root:root /mnt/swapfile
		chmod 600 /mnt/swapfile
		/sbin/mkswap /mnt/swapfile
		/sbin/swapon /mnt/swapfile
		
  EOH
end