namespace :deploy do
  before 'check:linked_files', 'upload:config', 'upload:keys'

  namespace :upload do
    desc 'upload key'
    task :keys do
      on roles(:app) do
        unless test("[ -f #{shared_path}/config/credentials/production.key ]")
          upload! 'config/credentials/production.key', "#{shared_path}/config/credentials/production.key"
        end
      end
    end

    desc 'upload config'
    task :config do
      on roles(:app) do
        unless test("[ -f #{shared_path}/config/database.yml ]")
          upload! 'config/database.yml.erb', "#{shared_path}/config/database.yml"
        end
      end
    end
  end
end
