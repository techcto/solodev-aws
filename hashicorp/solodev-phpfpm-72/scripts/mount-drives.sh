mkfs.ext4 /dev/xvdb
echo '/dev/xvdb /var/www/Solodev/clients/solodev ext4 defaults,auto,noexec 0 0'
mount -a
blockdev --setra 32 /dev/xvdb
/bin/dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
chown root:root /mnt/swapfile
chmod 600 /mnt/swapfile
/sbin/mkswap /mnt/swapfile
/sbin/swapon /mnt/swapfile