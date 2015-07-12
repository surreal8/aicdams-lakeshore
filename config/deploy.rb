# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'lakeshore'
set :repo_url, 'https://github.com/aic-collections/aicdams-lakeshore.git'
set :base_dir, "/usr/local/hydra"
set :aic_config_dir, "/usr/local/hydra/config"
set :user, 'awead'
set :deploy_to, "#{fetch(:base_dir)}/#{fetch(:application)}"
set :use_sudo, false
set :ssh_options, { keys: [File.join(ENV["HOME"], ".ssh", "id_rsa")] }
set :default_env, { path: "$PATH:#{fetch(:base_dir)}/bin" }

set :rails_env, 'production'
set :log_level, :debug
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"

set :linked_files, fetch(:linked_files, []).push(
  'config/blacklight.yml',
  'config/database.yml',
  'config/fedora.yml',
  'config/redis.yml',
  'config/secrets.yml',
  'config/solr.yml',
)
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
)
set :keep_releases, 10

namespace :deploy do

  # Create a symlink in the shared directory to the config directory
  # This keeps the configuration files separate from Capistratno's managed deploy directory.
  before 'check:linked_dirs', :link_config do
    on roles(:web) do
      execute "cd #{fetch(:deploy_to)}/shared; ln -sf #{fetch(:aic_config_dir)}"
    end
  end

end