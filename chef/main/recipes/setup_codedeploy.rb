#Setup Codedeploy
script "setup_codedeploy" do
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH
  
		aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
		chmod +x ./install
		./install auto
		sudo service codedeploy-agent start
		chkconfig codedeploy-agent on
		
  EOH
end