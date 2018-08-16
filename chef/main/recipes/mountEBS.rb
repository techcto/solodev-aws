document_root = node[:install][:document_root]
software_name = node[:install][:software_name]
client_name = node[:install][:client_name]

directory document_root+"/"+software_name do
  owner 'apache'
  group 'apache'
  mode '0770'
  action :create
end

directory document_root+"/"+software_name+"/clients" do
  owner 'apache'
  group 'apache'
  mode '0770'
  action :create
end

directory document_root+"/"+software_name+"/clients/"+client_name do
  owner 'apache'
  group 'apache'
  mode '0770'
  action :create
end