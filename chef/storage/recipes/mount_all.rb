#Make sure all drives are mounted
script "mount_all" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
		mount -a
  EOH
end