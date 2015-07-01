require 'capistrano/local_precompile'

app_env = ENV['RAILS_ENV']
set :repo_url, 'ssh://git@109.120.168.31:2298/home/git/tests.git'

set :deploy_to, "/home/slon/projects/#{app_env}"
set :scm, :git

set :log_level, :debug #:info

set :linked_files, %w{config/database.yml config/puma.rb config/initializers/secret_token.rb}
set :linked_dirs, %w{log tmp public/system}

set :branch, 'master'
set :keep_releases, 10

set :puma_rackup,     -> { File.join(current_path, 'config.ru') }
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf,       "#{shared_path}/config/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log,  "#{shared_path}/log/puma_access.log"
set :puma_role,       :app
set :puma_env,        fetch(:rack_env, fetch(:rails_env, app_env))
set :puma_threads,    [0, 16]
set :puma_workers,    0
set :puma_worker_timeout, nil
set :puma_init_active_record, false
set :puma_preload_app, true
set :puma_prune_bundler, false

namespace :deploy do

end

