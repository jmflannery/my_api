## This is the file that puma will use,
## you can configure with set :puma_env, 'production'

workers 0

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { 1 }
threads min_threads_count, max_threads_count

app_dir = File.expand_path("../../../../..", __FILE__)
shared_dir = "#{app_dir}/shared"

environment ENV.fetch("RAILS_ENV") { "production" }

bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
