Region = node[:install][:Region]
StackName = node[:install][:StackName]
DBUSER = node[:install][:DBUSER]
DBPASSWORD = node[:install][:DBPASSWORD]
client_name = node[:install][:client_name]
mongo_nodes = node[:install][:mongo_nodes]	

script "configure_mongo" do
	not_if { ::File.exists?("/root/initmongo.txt") }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
  my_string.to_s == ''
	if [-z "#{mongo_nodes}"]; then
		aws ec2 describe-instances --region #{Region} --filter Name=tag-key,Values='opsworks:layer:#{client_name}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts
	else
		aws ec2 describe-instances --region #{Region} --filter Name=tag-key,Values='opsworks:layer:#{client_name}-web' Name=tag-value,Values='#{mongo_nodes}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts
	fi

	MASTER=$(wget -O- -q http://169.254.169.254/latest/meta-data/local-ipv4)
	declare -i i=0
	while read host; do
	hosts[i]="$host"
	let i++
	done < /storagehosts

	#echo '${hosts[@]}'
	echo 'rs.initiate()' | mongo --host ${hosts[0]}
	sleep 60

	#echo 'rs.addArb("'$MASTER'")' 
	echo 'rs.add("'${hosts[1]}'")' | mongo --host ${hosts[0]}
	echo 'rs.addArb("'$MASTER'")' | mongo --host ${hosts[0]}
	echo 'rs.status()' | mongo --host ${hosts[0]}
	sleep 20

	touch /root/initmongo.txt
	echo 'cfg = rs.conf()' >> /root/mongouser.js
	echo 'cfg.members[0].host = "'${hosts[0]}':27017"' >> /root/mongouser.js
	echo 'rs.reconfig(cfg)' >> /root/mongouser.js
	echo 'use #{client_name}_views;' >> /root/mongouser.js
	echo 'db.createUser({"user": "#{DBUSER}", "pwd": "#{DBPASSWORD}", "roles": [ { role: "readWrite", db: "#{client_name}_views" } ] })' >> /root/mongouser.js 
	mongo --host ${hosts[0]} < /root/mongouser.js
	rm -Rf /root/mongouser.js
	#echo "" > /root/mongouser.js

	service mongod stop
	service mongod start
			
	EOH
end