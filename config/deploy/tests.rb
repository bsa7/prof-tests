app_name = 'tests'
server = '109.120.168.31:2298'
user_name = 'slon'
ssh_access_string = "#{user_name}@#{server}"
set :stage, app_name
set :rails_env, app_name

role :app, [ssh_access_string]
role :web, [ssh_access_string]
role :db, [ssh_access_string]
server server, user: user_name, roles: %w{web app db}
