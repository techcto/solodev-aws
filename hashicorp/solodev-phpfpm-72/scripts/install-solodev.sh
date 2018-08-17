#Install latest official release of Solodev
mkdir -p /tmp/Solodev
fn="$(aws s3 ls s3://solodev-release | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://solodev-release/$fn /tmp/Solodev/Solodev.zip
cd /tmp/Solodev/
unzip Solodev.zip
rm -Rf Solodev.zip
ls -al

#Solodev client mount
mkfs.ext4 /dev/xvdb
echo '/dev/xvdb /var/www/Solodev/clients/solodev ext4 defaults,auto,noexec 0 0'
blockdev --setra 32 /dev/xvdb

#Make swap for performance
mkdir -p /mnt/swapfile
/bin/dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
chown root:root /mnt/swapfile
chmod 600 /mnt/swapfile
/sbin/mkswap /mnt/swapfile
/sbin/swapon /mnt/swapfile