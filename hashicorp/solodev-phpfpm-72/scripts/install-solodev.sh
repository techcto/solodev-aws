#Install Solodev
mkdir -p /tmp/Solodev
fn="$(aws s3 ls s3://solodev-bamboo | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://solodev-bamboo/$fn /tmp/Solodev/Solodev.zip
cd /tmp/Solodev/
unzip Solodev.zip
rm -Rf Solodev.zip
ls -al

#Add Solodev to Crontab
(crontab -l 2>/dev/null; echo "*/2 * * * * php /var/www/Solodev/core/utils/restart.php") | crontab -