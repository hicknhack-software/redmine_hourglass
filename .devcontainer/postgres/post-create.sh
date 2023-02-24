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
git apply plugins/redmine_hourglass/.devcontainer/postgres/redmine5_i18n.patch

bundle

bundle exec rails config/initializers/secret_token.rb
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails redmine:plugins

# RAILS_ENV=test bundle exec rails db:drop
# RAILS_ENV=test bundle exec rails db:create
# RAILS_ENV=test bundle exec rails db:migrate
# RAILS_ENV=test bundle exec rails redmine:plugins
