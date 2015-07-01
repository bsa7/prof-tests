app_name = "tests"
set :stage, app_name
set :rails_env, app_name
role :app, %w{slon@109.120.168.31:2298}
role :web, %w{slon@109.120.168.31:2298}
role :db, %w{slon@109.120.168.31:2298}
server '109.120.168.31:2298', user: 'slon', roles: %w{web app db}
