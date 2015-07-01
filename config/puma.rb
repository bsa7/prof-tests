#!/usr/bin/env puma
threads 0, 32
daemonize true
projects_path        = "/tmp"
appname              = "tests"
application_path     = "/home/slon/projects/#{appname}"
environment railsenv = File.open("#{application_path}/env", "rb").read
pidfile              "#{projects_path}/shared/pids/#{appname}.pid"
state_path           "#{projects_path}/shared/sockets/#{appname}.state"
stdout_redirect      "#{application_path}/log/#{appname}.stdout.log", "#{application_path}/log/#{appname}.stderr.log"
bind                 "unix://#{projects_path}/shared/sockets/#{appname}.sock"
activate_control_app "unix://#{projects_path}/shared/sockets/#{appname}ctl.sock", { auth_token: 'cb7f897b8fcbcbf87bcf87bcf87bcfcbf87bcf879bcf87bcf87bcfbfbe2' }
