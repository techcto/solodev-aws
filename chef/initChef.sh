#!/bin/bash
curl -L https://www.opscode.com/chef/install.sh | bash
if [ ! -e /opt/chef/embedded/bin/berks ] ; then
    /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
    ln -s /opt/chef/embedded/bin/berks /usr/local/bin/berks
fi