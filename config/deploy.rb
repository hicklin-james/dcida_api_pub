# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'dcida'
set :scm, "git"
set :repo_url, ENV['REPO_GIT_URL']

set :stages, ["production"]
set :default_stage, "production"
set :ssh_options, {user: ENV['SSH_USER'], forward_agent: false}

set :unicorn_config_path, "/var/www/dcida/current/config/unicorn.rb" 
set :unicorn_pid, "/var/www/dcida/current/pids/unicorn.pid"

set :sidekiq_processes, 2
set :sidekiq_options_per_process, [
  "-q default -c 10 -L log/sidekiq_default.log",
  "-q data_export -c 10 -L log/sidekiq_data_export.log"
]

#set :ssh_options, :port => "port_number", :keys => "~/.ssh/id_rsa"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name

set :linked_files, %w(config/database.yml config/local_env.yml)
set :linked_dirs, %w(tmp public/system log pids sockets)

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
  task :build_missing_paperclip_styles do
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake 'paperclip:refresh:missing_styles'
        end
      end
    end
  end
  task :fix_counters do
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake 'admin:fix_counters'
        end
      end
    end
  end
end

after "deploy:publishing", "deploy:build_missing_paperclip_styles"
after "deploy:publishing", "deploy:fix_counters"
after 'deploy:publishing', 'deploy:restart'

namespace :task do
  desc 'Invoke a rake command on the remote server'
  task :invoke, [:command] => 'deploy:set_rails_env' do |task, args|
    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          rake args[:command]
        end
      end
    end
  end
end
