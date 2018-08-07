#Install Solodev
mkdir -p /home/ec2-user/Solodev
fn="$(aws s3 ls s3://solodev-bamboo | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://solodev-bamboo/$fn /home/ec2-user/Solodev/Solodev.zip
cd /home/ec2-user/Solodev/
unzip Solodev.zip
rm -Rf Solodev.zip
cd /home/ec2-user/
chown -Rf apache.apache Solodev
chmod -Rf 2770 Solodev
mv Solodev /var/www/

#Install solodev.conf
echo "<Directory \"/var/www/Solodev\">" >> /etc/httpd/conf.d/solodev.conf
echo "Options -Indexes" >> /etc/httpd/conf.d/solodev.conf
echo "Options FollowSymLinks" >> /etc/httpd/conf.d/solodev.conf
echo "#AllowOverride None" >> /etc/httpd/conf.d/solodev.conf
echo "AllowOverride All" >> /etc/httpd/conf.d/solodev.conf
echo "Order allow,deny" >> /etc/httpd/conf.d/solodev.conf
echo "Allow from all" >> /etc/httpd/conf.d/solodev.conf
echo "</Directory>" >> /etc/httpd/conf.d/solodev.conf
echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/solodev.conf
echo "Alias /core /var/www/Solodev/core/html_core" >> /etc/httpd/conf.d/solodev.conf
echo "Alias /CK /var/www/Solodev/core/CK" >> /etc/httpd/conf.d/solodev.conf
echo "Alias /api /var/www/Solodev/core/api" >> /etc/httpd/conf.d/solodev.conf
echo "ServerName localhost" >> /etc/httpd/conf.d/solodev.conf
echo "DocumentRoot /var/www/Solodev/core/solodevX/www" >> /etc/httpd/conf.d/solodev.conf
echo "</VirtualHost>" >> /etc/httpd/conf.d/solodev.conf
echo "IncludeOptional /var/www/Solodev/clients/solodev/Vhosts/*.*" >> /etc/httpd/conf.d/solodev.conf
echo "IncludeOptional /var/www/Solodev/clients/solodev/s.Vhosts/*.*" >> /etc/httpd/conf.d/solodev.conf