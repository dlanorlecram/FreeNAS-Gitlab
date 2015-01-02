#!/usr/local/bin/bash

# 10) Clone 
gitlabTag="v7.6.2"
/usr/local/bin/git clone https://gitlab.com/gitlab-org/gitlab-ce.git /usr/home/git/gitlab
cd /usr/home/git/gitlab
/usr/local/bin/git checkout $gitlabTag

# 11) Copy example configs to final place
/bin/cp config/gitlab.yml.example config/gitlab.yml
/bin/cp config/unicorn.rb.example config/unicorn.rb
/bin/cp config/database.yml.mysql config/database.yml
/bin/cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

# 12) Fix paths for FreeBSD (to avoid symlink of /home/). Change mysql password for git user.
sed -i '.bak' 's/usr\/bin\/git/usr\/local\/bin\/git/g' config/gitlab.yml
sed -i '.bak' 's/home\/git/usr\/home\/git/g' config/gitlab.yml
sed -i '.bak' "s/secure password/\$password/g" config/database.yml

# 13) Set default config
git config --global user.name "GitLab"
git config --global user.email "gitlab@freenas.lan"
git config --global core.autocrlf input

# 14) Fix path permissions:
chmod -R o-rwx config/
chown -R git log/
chown -R git tmp/
chmod -R u+rwX log/
chmod -R u+rwX tmp/
chmod -R u+rwX tmp/pids/
chmod -R u+rwX tmp/sockets/
chmod -R u+rwX public/uploads
mkdir -p /home/git/gitlab-satellites
chmod u+rwx,g=rx,o-rwx /home/git/gitlab-satellites


# 15) Install Gems
# Set build options specific for BSD
bundle config build.nokogiri --with-opt-include=/usr/local/include/ --with-opt-lib=/usr/local/lib/
bundle config build.charlock_holmes --with-opt-include=/usr/local/include/ --with-opt-lib=/usr/local/lib/
bundle install --deployment --without development test postgres aws

# 16) Install GitLab Shell
bundle exec rake gitlab:shell:install[v2.4.0] REDIS_URL=redis://localhost:6379 RAILS_ENV=production
sed -i '.bak' 's/: \/home\/git/: \/usr\/home\/git/g' /home/git/gitlab-shell/config.yml

# 17) Initialize Database, precompile assets and check gitlab setup
echo -n yes | bundle exec rake gitlab:setup RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rake gitlab:env:info RAILS_ENV=production