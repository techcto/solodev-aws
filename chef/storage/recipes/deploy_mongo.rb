template 'limits.conf' do
  path "/etc/security/limits.conf"
  source 'limits.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template '90-nproc.conf' do
  path "/etc/yum.repos.d/10gen.repo"
  source '90-nproc.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template 'mongodb-org-4.0.repo' do
  path '/etc/yum.repos.d/mongodb-org-4.0.repo'
  source 'mongodb-org-4.0.repo.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template 'mongod.conf' do
  path "/etc/mongod.conf"
  source 'mongod.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

#Install Mongo
script "install_mongo" do
	not_if { ::File.exists?('/mongo/data/journal') }
  interpreter "bash"
  user "root"
  cwd "/root"
  code <<-EOH 
  
    yum install -y mongodb-org
    
    chkconfig mongod on
		service mongod status
		mongo --eval "db.getSiblingDB('admin').shutdownServer()"
		
    mkdir -p /mongo/data/journal /mongo/log
    mkdir -p /mongo/data/arb
    chown -Rf mongod:mongod /mongo
    chown -Rv mongod:mongod /var/lib/mongo
    
		service mongod start
		sleep 20
        
  EOH
end