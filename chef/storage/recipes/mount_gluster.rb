VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]

#Mount Gluster Brick
script "mount_gluster" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
  	#Get current BRICKS that are online
		ACTIVEBRICKS=()
		while read -r line; do
			field=($(echo $line))
			case ${field[0]} in
			Brick) 
				ACTIVEBRICKS=("${ACTIVEBRICKS[@]}" $(echo ${field[@]:2} | awk '{print $2}' | awk '{split($0,brickip,":"); print brickip[1]}'))
				;;
			esac
		done < <( gluster volume status ${VOLUMENAME} detail)
		  
		#Get new mount if old mount is no longer available
	  echo 'cd /root' > /root/remount.sh
		echo 'umount -f /mnt/glusterfs/'${VOLUMENAME}'' >> /root/remount.sh
		echo 'sleep 10' >> /root/remount.sh
		echo 'mount -t glusterfs '${ACTIVEBRICKS[0]}':/'${VOLUMENAME}' /mnt/glusterfs/'${VOLUMENAME}'' >> /root/remount.sh
		echo 'sleep 10' >> /root/remount.sh
		chmod 700 /root/remount.sh
		/root/remount.sh
		
		sed -i.bak '/glusterfs/d' /etc/fstab
		echo "$(head -n 1 /storagehosts|cut -f1):/#{VolumeName} #{document_root}/#{software_name}/clients/#{client_name} glusterfs defaults 0 0" >> /etc/fstab
  EOH
end