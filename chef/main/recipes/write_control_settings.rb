client_name = node[:install][:client_name]
control_root = node[:install][:control_root]
	
template 'Client_Settings.xml' do
	not_if { ::File.exists?("#{control_root}/Client_Settings.xml") }
  path "#{control_root}/Client_Settings.xml"
  source 'Client_Settings.xml.erb'
  owner 'apache'
  group 'apache'
  mode '0755'
end