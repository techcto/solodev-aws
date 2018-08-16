#Chef::Log.info(node[:database][:host])
#yml_string = YAML::dump(node[:apache].to_hash)
#Chef::Log.info(yml_string)
Chef::Log.level = :debug
VolumeName = node[:install][:VolumeName]
StackName = node[:install][:StackName]
Region = node[:install][:Region]
StorageWaitHandle = node[:install][:StorageWaitHandle]
BrickName = node[:install][:client_name]

#Install Software
script "heal_gluster" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH

		#!/bin/bash

		STACKNAME=#{StackName}
		REGION=#{Region}

		if [ -f /root/remount.sh ]
		  then
		    #/root/remount.sh
		    #rm -Rf /root/remount.sh
		    REMOUNT = 1;
		fi

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

		#Check amazon for current storage hosts
		AWSHOSTS=$(aws ec2 describe-instances --region $REGION --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
		aws ec2 describe-instances --region #{Region} --filter Name=instance-state-name,Values=running Name=tag-key,Values='opsworks:layer:#{BrickName}-storage' Name=tag-value,Values='#{StackName}-SolodevStorage' --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text > /storagehosts

		#Get current volume Name
		VOLUMENAME=$(gluster volume info | egrep "Name" | awk -F \: '{print $2}')
		VOLUMENAME=$(echo $VOLUMENAME | sed -e 's/^ *//' -e 's/ *$//')

		#Get current mounted BRICKS, some bricks may not be online anymoreinfo
		MOUNTEDBRICKS=()
		for brick in $(gluster volume info ${VOLUMENAME} | awk '/^Brick[0-9]*:/ {print $2}'); do
			MOUNTEDBRICKS=("${MOUNTEDBRICKS[@]}" $(echo $brick | awk '{split($0,brickip,":"); print brickip[1]}'))
		done;

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

		#Check AWSHOSTS for new BRICKS
		AVAILABLEBRICKS=()
		set -- junk $AWSHOSTS
		shift
		for host; do
			if in_array ACTIVEBRICKS "$host"; then 
				echo "$host is already an active brick."
			else 
				echo "$host is not an active brick. Add host into available bricks."
				AVAILABLEBRICKS=("${AVAILABLEBRICKS[@]}" $host)
				gluster peer probe $host;
				ADDBRICKS=1
			fi
		done
		sleep 10

		#Configure Cluster
		if [ ${#ACTIVEBRICKS[@]} -eq 0 ]; then
		    #If no ACTIVEBRICKS. We need to reconfigure the cluster from scratch.
		    #FYI, we have lost all data, so we also need to restore from backup.
		    
		    #Step 1) Loop through MOUNTEDBRICKS and detach
			    for host in "${MOUNTEDBRICKS[@]}"
					do
						if in_array ACTIVEBRICKS "$host"; then 
							#Detach
							gluster peer detach $host force
						fi
					done 
				
				#Step 2) Stop Volume, Delete Volume and Unmount
					echo "y" | gluster volume stop $VOLUMENAME
					echo "y" | gluster volume delete $VOLUMENAME
					umount "/mnt/glusterfs/$VOLUMENAME"
				
				#Step 3) Create Volume, Start, Mount
					CLUSTERSIZE=${#AVAILABLEBRICKS[@]}
					set -- junk $AWSHOSTS
					shift
					for host; do
						BRICKS=$BRICKS" $host:/bricks/#{BrickName}"
					done;
					gluster volume create $VOLUMENAME replica $CLUSTERSIZE transport tcp $BRICKS force
			    gluster volume start $VOLUMENAME
			    mount -t glusterfs "$host:/$VOLUMENAME /mnt/glusterfs/$VOLUMENAME"
		elif [ ${#ACTIVEBRICKS[@]} -eq ${#MOUNTEDBRICKS[@]} ] && [ ${#ADDBRICKS} -ne 1 ]; then 
			#The number of available bricks matches the number of mounted gluster bricks
			echo "No Gluster problems to report"
		else
		    #We have ACTIVEBRICKS. We need to modify existing cluster.
		    CLUSTERSIZE=${#MOUNTEDBRICKS[@]}
		    
		    #Step 1) Loop through MOUNTEDBRICKS to see if they are active.
			    for host in ${MOUNTEDBRICKS[@]}
					do
						if in_array ACTIVEBRICKS "$host"; then 
							#Brick is active
							echo "Brick: $host is active."
						else
							#Brick is not active, remove brick from cluster
							CLUSTERSIZE=$((CLUSTERSIZE-1))
							echo "y" | gluster volume remove-brick ${VOLUMENAME} replica $CLUSTERSIZE $host:/bricks/${VOLUMENAME} force
							gluster peer detach $host
								
							#Get new mount if old mount is no longer available
						  echo 'cd /root' > /root/remount.sh
							echo 'umount -f /mnt/glusterfs/'${VOLUMENAME}'' >> /root/remount.sh
							echo 'sleep 10' >> /root/remount.sh
							echo 'mount -t glusterfs '${ACTIVEBRICKS[0]}':/'${VOLUMENAME}' /mnt/glusterfs/'${VOLUMENAME}'' >> /root/remount.sh
							echo 'sleep 10' >> /root/remount.sh
							chmod 700 /root/remount.sh
							#/root/remount.sh
							
							sed -i.bak '/glusterfs/d' /etc/fstab
							echo "$(head -n 1 /storagehosts|cut -f1):/#{VolumeName} /mnt/glusterfs/#{VolumeName} glusterfs defaults 0 0" >> /etc/fstab
						fi
					done 
				
				#Step 2) Loop through AVAILABLEBRICKS to see if they are active.  
					for host in ${AVAILABLEBRICKS[@]}
					do
						if in_array ACTIVEBRICKS $host; then 
							#Brick is active
							echo "Brick: $host is active."
						else
							#Brick is not active, add brick to cluster
							echo "Brick: $host is not active."
							CLUSTERSIZE=$((CLUSTERSIZE+1))
							gluster volume add-brick ${VOLUMENAME} replica $CLUSTERSIZE $host:/bricks/${VOLUMENAME} force
							
							#Step 3) #After Gluster Bricks are Reconfigured, Heal volume
							sleep 10
							echo "Heal Gluster"
							gluster volume heal ${VOLUMENAME} full
						fi
					done 
		fi

		exit 0

  EOH
end