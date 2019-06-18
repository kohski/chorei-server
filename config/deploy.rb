# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '3.6.0'

# Application name
set :application, 'chorei-server'

# git repositroy
set :repo_url, 'https://github.com/kohski/chorei-server'

# deploy branch
set :branch, ENV['BRANCH'] || 'master'

# directory in AWS
set :deploy_to, '/var/www/chorei-server'

# folder and files to attach symbolic link
set :linked_files, %w[.env config/secrets.yml]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets public/uploads]

# number of version
set :keep_releases, 5

# Ruby version
set :rbenv_ruby, '2.5.1'
set :rbenv_type, :system

# error log level
# :info is normal as prduction environment
set :log_level, :info

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'Create database'
  task :db_create do
    on roles(:db) do |_host|
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  desc 'Run seed'
  task :seed do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
