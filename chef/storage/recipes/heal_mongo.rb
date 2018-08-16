#Chef::Log.info(node[:database][:host])
#yml_string = YAML::dump(node[:apache].to_hash)
#Chef::Log.info(yml_string)

REPLICAS=()
ARBITERS=()
BADHOSTS=()
StackName = node[:install][:StackName]
Region = node[:install][:Region]
BrickName = node[:install][:client_name]
mongo_nodes = node[:install][:mongo_nodes]
control_root = node[:install][:control_root]

#Install Software
script "heal_mongo" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH

	#!/bin/bash

	in_array() {
	    local haystack=${1}[@]
	    local needle=${2}
	    for i in ${!haystack}; do
	        if [[ ${i} == ${needle} ]]; then
	            return 0
	        fi
	    done
	    return 1
	}

	SETNAME=$(echo 'rs.status()'| mongo | egrep "set" | awk -F \\" '{print $4}'| cut -f 1 -d :)

	#Add buffer to wait for servers to go out of service.
	sleep 50

	#http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
	if [-z "#{mongo_nodes}"]; then
		AWSHOSTS=$(aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
		echo "aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text"  >> /mongolog.txt
		aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts
	else
		AWSHOSTS=$(aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-web' Name=tag-value,Values='#{mongo_nodes}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
		echo "aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-web' Name=tag-value,Values='#{mongo_nodes}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text"  >> /mongolog.txt
		aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-web' Name=tag-value,Values='#{mongo_nodes}' Name=tag-key,Values='opsworks:stack' Name=tag-value,Values='#{StackName}' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts
	fi


	#Copy hosts to mongo file
	echo "cp -f /storagehosts #{control_root}/mongohosts.txt"  >> /mongolog.txt
	cp -f /storagehosts #{control_root}/mongohosts.txt
	echo "#{StackName}" > #{control_root}/stackname.txt
	echo $SETNAME > #{control_root}/SETNAME.txt

	#Loop through status and get ids
	IDS=()
	for id in `echo 'rs.status()' | mongo | egrep "_id" | awk -F : '{print $2}'| cut -f 1 -d ,`; do 
		echo $id
		IDS=(${IDS[@]} "$id")
	done 

	## Check whether host is slave and in good state 
	HOSTCOUNT=0
	for i in `echo 'rs.status()' | mongo | egrep "name" | awk -F \\" '{print $4}'| cut -f 1 -d :`; do 
		echo $i
		TheState=$(echo 'rs.status()'| mongo --host $i | grep -i mystate | awk -F : '{print $2}' | cut -f 1 -d ,) 
		
		CURRENT_ID=${IDS[$HOSTCOUNT]}
		
		if [ $TheState ]; then 
			echo '$i is accessible.'
			
			#Add into available replicas array
			host=$(echo $i | sed -r 's/ip-//g' | sed -r 's/-/\./g')
			
			#Test if master
			IsMaster=$(echo 'db.isMaster()'| mongo --host $i | grep ismaster| awk -F : '{print $2}' | cut -f 1 -d ,)
			if [ $IsMaster == "true" ]; then 
				echo '$i is Master.'
				REPLICAS[$CURRENT_ID]=$host
				MASTER=$host
			elif [ $TheState == "7" ]; then 
				ARBITERS[$CURRENT_ID]=$host
			else
				echo '$i is Slave.'
				REPLICAS[$CURRENT_ID]=$host
				REPLICA=$host
			fi
		else
			echo '$i not accessible.  Remove from Replica'
			
			#Add into remove replicas array
			BADHOSTS=(${BADHOSTS[@]} $i)
		fi 
		
		HOSTCOUNT=$((HOSTCOUNT+1))
	done 

	if [ $MASTER ]; then
		MONGOHOST=$MASTER
	else
		MONGOHOST=$REPLICA
	fi

	#echo "${REPLICAS[@]}"
	#Check available hosts to see if we have new available replicas to add
	HOSTID=$((CURRENT_ID+1))
	set -- junk $AWSHOSTS
	shift
	for host; do
		if in_array REPLICAS "$host"; then 
			echo '$host is already a replica'
		else 
			echo '$host is not a replica. Add host into available replicas'
			REPLICAS[$HOSTID]=$host
			HOSTID=$((HOSTID+1))
			ADDHOSTS=1
		fi
	done

	rm -Rf /root/mongoconfig.js
	echo -ne 'config = {' > /root/mongoconfig.js
	echo -ne '"_id" : "'$SETNAME'", ' >> /root/mongoconfig.js
	echo -ne '"members" : [' >> /root/mongoconfig.js
	REPLICACOUNT=0
	#Loop through available replicas and reconfigure mongo replica group

	for id in "${!REPLICAS[@]}"; do
		if [ $REPLICACOUNT -gt "0" ]; then
			echo -ne ', ' >> /root/mongoconfig.js
		fi
		echo -ne '{"_id" : '$id', "host" : "'${REPLICAS[$id]}':27017"}' >> /root/mongoconfig.js
		REPLICACOUNT=$((REPLICACOUNT+1))
	done

	for id in "${!ARBITERS[@]}"; do
		if [ $REPLICACOUNT -gt "0" ]; then
			echo -ne ', ' >> /root/mongoconfig.js
		fi
		echo -ne '{"_id" : '$id', "host" : "'${ARBITERS[$id]}':27017", "arbiterOnly" : true}' >> /root/mongoconfig.js
		REPLICACOUNT=$((REPLICACOUNT+1))
	done

	echo -ne ']' >> /root/mongoconfig.js
	echo '}' >> /root/mongoconfig.js
	echo 'rs.reconfig(config, {force : true})' >> /root/mongoconfig.js

	if [ $BADHOSTS ] || [ $ADDHOSTS ]; then 
		mongo --host $MONGOHOST < /root/mongoconfig.js
	fi

	service mongod stop
	service mongod start

	exit 0

  EOH
end