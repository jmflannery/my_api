namespace :deploy do
  def process_erb(path)
    StringIO.new(ERB.new(File.read(path)).result(binding))
  end

  namespace :upload do
    desc 'Upload database config'
    task :db_config do
      on roles(:app) do
        unless test("[ -f #{shared_path}/config/database.yml ]")
          upload! 'config/database.example.yml', "#{shared_path}/config/database.yml"
        end
      end
    end

    desc 'Upload production key for credentials'
    task :key do
      on roles(:app) do
        unless test("[ -f #{shared_path}/config/credentials/production.key ]")
          upload! 'config/credentials/production.key', "#{shared_path}/config/credentials/production.key"
        end
      end
    end
  end

  namespace :nginx do
    desc 'Install nginx config'
    task :install do
      on roles(:web) do
        within release_path do
          destination_path = "#{shared_path}/tmp/my_api_nginx.conf"
          template_path    = 'config/deploy/templates/nginx.erb'

          unless test("[ -f #{destination_path} ]")
            # result = process_erb(template_path)
            execute :echo, Shellwords.escape(process_erb(template_path).read), '>', destination_path
          end
        end
      end
    end
  end

  namespace :db do
    desc 'Create the database'
    task :create do
      on roles(:app) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rails, 'db:create'
          end
        end
      end
    end
  end

  task :cold do
    before 'deploy:check:linked_files', 'deploy:upload:db_config'
    before 'deploy:check:linked_files', 'deploy:upload:key'
    before 'deploy:migrate',            'deploy:db:create'
    before 'deploy:finished',           'puma:install'
    before 'deploy:finished',           'deploy:nginx:install'

    invoke :deploy
  end
end
