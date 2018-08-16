DBUSER = node[:install][:DBUSER]
DBPASSWORD = node[:install][:DBPASSWORD]
client_name = node[:install][:client_name]	  
	
template 'mongod.conf' do
	not_if { ::File.exists?('/etc/mongod.conf') }
  path "/etc/mongod.conf"
  source 'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

script "mongo_user" do
	not_if { ::File.exists?('/root/initmongo.txt') }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH

		touch /root/initmongo.txt
		echo 'use #{client_name}_views;' >> /root/mongouser.js
		echo 'db.createUser({"user": "#{DBUSER}", "pwd": "#{DBPASSWORD}", "roles": [ { role: "readWrite", db: "#{client_name}_views" } ] })' >> /root/mongouser.js 
		mongo < /root/mongouser.js
		rm -Rf /root/mongouser.js
		
	EOH
end