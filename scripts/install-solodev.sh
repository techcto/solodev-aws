#Install Solodev
fn="$(aws s3 ls s3://solodev-bamboo | sort | tail -n 1 | awk '{print $4}')"
aws s3 cp s3://solodev-bamboo/$fn /tmp/Solodev.zip
cd /tmp/
unzip Solodev.zip
rm -Rf Solodev.zip
cd /tmp/Solodev
