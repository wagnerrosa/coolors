#!/usr/bin/env bash
# Render build script. Migrations run here because preDeployCommand is paid-only,
# and the free plan has no shell access for one-off commands.
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
bundle exec rails db:seed
