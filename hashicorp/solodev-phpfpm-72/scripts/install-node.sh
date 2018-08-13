#Init
mkdir -p /var/www/.npm-global
echo 'export NODE_PATH=/var/www/.npm-global/lib/node_modules' >> /var/www/.npmrc
echo 'export PATH=$PATH:/var/www/.npm-global/bin' >> /var/www/.npmrc
export PATH=/var/www/.npm-global/bin:$PATH
curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -

#Execute
yum install -y --enablerepo=nodesource nodejs
npm install -g autoprefixer clean-css-cli nodemon npm-run-all postcss-cli postcss-discard-empty shx uglify-js node-sass
npm config set prefix '/var/www/.npm-global'

#Permissions
chmod -Rf 2770 /var/www/.npm-global
chown -Rf apache.apache /var/www/.npm-global