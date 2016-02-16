app_name = "tests"
user_name = "slon"
desc "restart puma on production server"

task :restart_puma do
  on roles(:app) do
    info "restart puma on production server"
    execute "/bin/bash -l -c \"cd /home/#{user_name}/projects/#{app_name}/current && ./do puma_restart\""
  end
end
