app_name = "tests"
user_name = "slon"
desc "restart sidekiq on production server"

task :restart_sidekiq do
  on roles(:app) do
    info "restart sidekiq on production server"
    execute "/bin/bash -l -c \"cd /home/#{user_name}/projects/#{app_name}/current && ./do sidekiq_restart\""
  end
end
