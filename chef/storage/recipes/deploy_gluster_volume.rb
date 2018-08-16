VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
ReplicaNum = node[:install][:ReplicaNum]
client_name = node[:install][:client_name]

#Install Software
script "mount_gluster" do
	not_if { ::File.exists?("/storagehosts") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
		aws ec2 describe-instances --region #{Region} --filter Name=tag-key,Values='opsworks:layer:#{client_name}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts
		
		for host in $(cat /storagehosts);do gluster peer probe $host;done
		sleep 50
		
		gluster volume create #{VolumeName} replica #{ReplicaNum} transport tcp $(sed -r 's!( +|\\t+|$)!:/bricks/#{VolumeName} !g' /storagehosts) force
		gluster volume set #{VolumeName} auth.allow '*'
		gluster volume set #{VolumeName} nfs.export-volumes on
		gluster volume set #{VolumeName} performance.io-thread-count 32
		gluster volume set #{VolumeName} network.ping-timeout "150"
		
		gluster volume start #{VolumeName}
		
		mkdir -p /mnt/glusterfs/#{VolumeName}
		mount -t glusterfs $(head -n 1 /storagehosts|cut -f1):/#{VolumeName} /mnt/glusterfs/#{VolumeName}
		echo "$(head -n 1 /storagehosts|cut -f1):/#{VolumeName} /mnt/glusterfs/#{VolumeName} glusterfs defaults 0 0" >> /etc/fstab
   
  EOH
end