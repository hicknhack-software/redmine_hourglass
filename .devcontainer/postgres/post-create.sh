#!/bin/bash
set -e

. ${NVM_DIR}/nvm.sh
nvm install --lts

sudo chown -R vscode:vscode .
sudo chmod ugo+w /bundle

git config --global --add safe.directory /redmine
git init
git remote add origin https://github.com/redmine/redmine.git
git fetch
git checkout -t origin/${REDMINE_VERSION} -f

bundle

bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate
bundle exec rake redmine:plugins

# bundle exec rake db:drop RAILS_ENV=test
# bundle exec rake db:create RAILS_ENV=test
# bundle exec rake db:migrate RAILS_ENV=test
# bundle exec rake redmine:plugins:migrate RAILS_ENV=test
