threads 0, 8
daemonize true
rails_env = File.open("env", "rb").read
if rails_env == "development"
  app_name = Dir.pwd[/[^\/]+$/]
  tmp_path = "/tmp/shared"
else
  deploy_path = Dir.pwd.gsub(%r((\/releases\/|\/current).+$), '')
  app_name = deploy_path[/[^\/]+$/]
  rails_env = app_name
  tmp_path = "#{deploy_path}/shared/tmp"
end
application_path     = Dir.pwd
environment railsenv = rails_env
pidfile                "#{tmp_path}/pids/#{app_name}.pid"
state_path             "#{tmp_path}/sockets/#{app_name}.state"
stdout_redirect        "#{application_path}/log/#{app_name}.stdout.log", "#{application_path}/log/#{app_name}.stderr.log"
bind                   "unix://#{tmp_path}/sockets/#{app_name}.sock"
activate_control_app   "unix://#{tmp_path}/sockets/#{app_name}ctl.sock", {
  auth_token: File.open("token_file", "rb").read
}
