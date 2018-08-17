document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]

instance = search("aws_opsworks_instance", "self:true").first # this gets the databag for the instance

template 'Client_Settings.xml' do
	not_if { ::File.exists?("#{document_root}/#{software_name}/clients/#{client_name}/Client_Settings.xml") }
  path "#{document_root}/#{software_name}/clients/#{client_name}/Client_Settings.xml"
  variables( 
  	private_ip: "instance['private_ip']"
  )
  action :create
  source 'Client_Settings.xml.erb'
  mode '0755'
end