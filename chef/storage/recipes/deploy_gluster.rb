VolumeName = node[:install][:VolumeName]

#Deploy Gluster
script "deploy_gluster" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
		#Set timezone - TODO make this option to pass in
    perl -pi -e 's|ZONE=\"UTC\"|ZONE=\"America/New_York\"|g' /etc/sysconfig/clock
		ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
		
    #Make Gluster Brick
    #mkfs.ext4 -m 1 -L gluster /dev/sdb
    #mkdir -p /bricks/#{VolumeName}/
    #echo '/dev/sdb /bricks/#{VolumeName} ext4 defaults 1 2' >> /etc/fstab
    #mount -a
    rm -Rf /bricks/#{VolumeName}/*
    perl -pi -e "s/LOG_LEVEL=''/LOG_LEVEL='ERROR'/g" /etc/init.d/glusterd
    
    setfattr -x trusted.glusterfs.volume-id /bricks/#{VolumeName}
		setfattr -x trusted.gfid /bricks/#{VolumeName}
		volume set #{VolumeName} nfs.disable 
    
    chkconfig ntpd on
		service ntpd start
		
		# Add Swap
  	/bin/dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
		chown root:root /mnt/swapfile
		chmod 600 /mnt/swapfile
		/sbin/mkswap /mnt/swapfile
		/sbin/swapon /mnt/swapfile
		
  EOH
end