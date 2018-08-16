VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]

#Mount Client Brick
script "mount_client" do
	not_if { ::File.exists?("/etc/yum.repos.d/glusterfs-epel.repo") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH

		#Install Gluster
	  wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/EPEL.repo/glusterfs-epel.repo
		sed -i 's/$releasever/6/g' /etc/yum.repos.d/glusterfs-epel.repo
		
		yum -y --enablerepo=epel install glusterfs-server glusterfs glusterfs-fuse
		chkconfig glusterd on
		service glusterd start
		
		#Mount Gluster bucket
		aws ec2 describe-instances --region #{Region} --filter Name=tag-key,Values='opsworks:layer:#{client_name}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts
		mkdir -p #{document_root}/#{software_name}/clients/#{client_name}
		mount -t glusterfs $(head -n 1 /storagehosts|cut -f1):/#{VolumeName} #{document_root}/#{software_name}/clients/#{client_name}
		echo "$(head -n 1 /storagehosts|cut -f1):/#{VolumeName} #{document_root}/#{software_name}/clients/#{client_name} glusterfs defaults 0 0" >> /etc/fstab
  EOH
end