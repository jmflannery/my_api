namespace :rbenv do
  desc "Update rbenv and ruby-build"
  task :upgrade do
    on roles(:app) do
      rbenv_path = capture("echo #{fetch(:rbenv_path)}").strip

      within rbenv_path do
        execute :git, "pull"
      end

      # Update ruby-build for new Ruby version support
      within "#{rbenv_path}/plugins/ruby-build" do
        execute :git, "pull"
      end

      # Rehash rbenv shims
      execute "#{fetch(:rbenv_init)} && rbenv rehash"
      puts "rbenv and ruby-build have been updated."
    end
  end

  desc 'Update the ruby version'
  task :update_ruby do
    target_version = File.read('.ruby-version').strip.gsub(/^ruby-/, '')

    on roles(:app) do
      installed_versions = capture("#{fetch(:rbenv_init)} && rbenv versions").lines

      if installed_versions.any? { |line| line.include?(target_version) }
        puts "Ruby #{target_version} is already installed on the server."
      else
         invoke 'rbenv:upgrade'

        # Install the new Ruby version
        execute "#{fetch(:rbenv_init)} && rbenv install #{target_version}"
        execute "#{fetch(:rbenv_init)} && rbenv rehash"
        puts "Ruby #{target_version} installed on the server."
      end
    end
  end
end
