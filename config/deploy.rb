# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "my_api"
set :repo_url, "git@github.com:jmflannery/my_api.git"
set :deploy_to, "/var/www/apps/#{fetch(:application)}"

# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, :main

set :rbenv_type, :user # or :system, or :fullstaq (for Fullstaq Ruby), depends on your rbenv setup
set :rbenv_ruby, '3.4.1'

set :default_env, {
  PATH: "$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
}

set :rbenv_init, 'eval "$(~/.rbenv/bin/rbenv init -)"'

append :linked_files, 'config/credentials/production.key'
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"
