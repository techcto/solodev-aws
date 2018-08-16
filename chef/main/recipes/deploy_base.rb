document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]
apache_conf_dir = node[:install][:apache_conf_dir]
conf_name = client_name

directory document_root+'/'+software_name+'/clients/'+client_name+'/Vhosts' do
	not_if do ::File.exists?("#{document_root}/#{software_name}/clients/#{client_name}/Vhosts") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end

directory document_root+'/'+software_name+'/clients/'+client_name+'/s.Vhosts' do
	not_if do ::File.exists?("#{document_root}/#{software_name}/clients/#{client_name}/s.Vhosts") end
  owner 'apache'
  group 'apache'
  mode '0755'
  recursive true
  ignore_failure true
  action :create
end

#Install CMS Apache conf
template conf_name+'.conf' do
	not_if do ::File.exists?(apache_conf_dir+'/'+client_name+'.conf') end
  path apache_conf_dir+'/'+client_name+'.conf'
  source conf_name+'.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end