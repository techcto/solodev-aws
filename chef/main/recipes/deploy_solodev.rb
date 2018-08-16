document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]
ADMINUSER = node[:install][:ADMINUSER]
ADMINPASSWORD = node[:install][:ADMINPASSWORD]
WEBSITE = node[:install][:WEBSITE]
THEME = node[:install][:THEME]

#Backup Software
script "backup_software" do
	only_if  { ::File.exists?("#{document_root}/#{software_name}/modules") }
	interpreter "bash"
	user "root"
	cwd "/root"
	code <<-EOH

		rm -Rf #{document_root}/#{software_name}/old
		mkdir "#{document_root}/#{software_name}/old"
		mv #{document_root}/#{software_name}/modules #{document_root}/#{software_name}/old/
		mv #{document_root}/#{software_name}/core #{document_root}/#{software_name}/old/
		mv #{document_root}/#{software_name}/vendor #{document_root}/#{software_name}/old/
		mv #{document_root}/#{software_name}/composer.json #{document_root}/#{software_name}/old/
		mv #{document_root}/#{software_name}/composer.lock #{document_root}/#{software_name}/old/
		rm -Rf #{document_root}/#{software_name}/license.php

	EOH
end

#Install Software
script "install_software" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
  	#Make sure default html folder exists.  This will not be used.
  	mkdir -p #{document_root}/html
  	mkdir -p #{document_root}/#{software_name}
  
  	#Install Solodev CMS
	  	mkdir -p /root/Solodev
		fn="$(aws s3 ls s3://solodev-release | sort | tail -n 1 | awk '{print \$4}')"
		aws s3 cp s3://solodev-release/$fn /root/Solodev/Solodev.zip
		cd /root/Solodev
		unzip Solodev.zip
		rm -Rf Solodev.zip
		
		service httpd stop

		cd ..
		chown -Rf apache.apache Solodev
		chmod -Rf 2770 Solodev
		mv Solodev/modules #{document_root}/#{software_name}/
		mv Solodev/core #{document_root}/#{software_name}/
		mv Solodev/vendor #{document_root}/#{software_name}/
		mv Solodev/license.php #{document_root}/#{software_name}/
		mv Solodev/composer.json #{document_root}/#{software_name}/
		mv Solodev/composer.lock #{document_root}/#{software_name}/
		rm -Rf /root/Solodev
		
		service httpd start
		
		echo "php #{document_root}/#{software_name}/core/update.php #{ADMINUSER} #{ADMINPASSWORD}" >> /root/phpinstall.log
		php #{document_root}/#{software_name}/core/update.php #{ADMINUSER} #{ADMINPASSWORD} #{WEBSITE} #{THEME} >> /root/phpinstall.log
		
		#chown -Rf apache.apache #{document_root}/#{software_name}/clients
		#chmod -Rf 2770 #{document_root}/#{software_name}/clients
		
	EOH
end