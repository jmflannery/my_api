# config valid for current version and patch releases of Capistrano
lock "~> 3.18.0"

set :application, "my_api"
set :repo_url, "git@github.com:jmflannery/my_api.git"
set :deploy_to, "/var/www/apps/#{fetch(:application)}"

# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, :main

set :rbenv_type, :user # or :system, or :fullstaq (for Fullstaq Ruby), depends on your rbenv setup
set :rbenv_ruby, '3.3.0'

append :linked_files, 'config/database.yml', 'config/credentials/production.key'
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"
