#!/bin/bash
cd /opt/redmine/redmine-4.1.1/config/ && bundle install && \
bundle exec rake generate_secret_token && \
RAILS_ENV=production bundle exec rake db:migrate && \
RAILS_ENV=production bundle exec rake redmine:load_default_data;