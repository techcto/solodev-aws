EFSHOST = node[:install][:EFSHOST]
VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]

#Mount Client Brick
script "mount_client" do
	not_if { ::File.exists?("/home/ec2-user/efs") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
	yum -y nfs-utils
	mkdir -p #{document_root}/#{software_name}/clients/#{client_name}
	
	mount -t nfs4 -o nfsvers=4.1 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).#{EFSHOST}.efs.#{Region}.amazonaws.com:/ #{document_root}/#{software_name}/clients/#{client_name}     
	echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).#{EFSHOST}.efs.#{Region}.amazonaws.com:/ #{document_root}/#{software_name}/clients/#{client_name} nfs defaults 0 0" >> /etc/fstab
	
	chown -Rf apache.apache #{document_root}/#{software_name}/clients/#{client_name}
	chmod -Rf 2770 #{document_root}/#{software_name}/clients/#{client_name}
	
	touch /home/ec2-user/efs

  EOH
end