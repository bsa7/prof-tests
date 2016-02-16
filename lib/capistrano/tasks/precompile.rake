namespace :deploy do
  namespace :assets do

    Rake::Task['deploy:assets:precompile'].clear_actions

    desc 'Precompile assets locally and upload to servers'
    task :precompile do
      on roles(fetch(:assets_roles)) do

        execute 'rm -rf public/assets/*'
        run_locally do
          with rails_env: fetch(:rails_env) do
            execute 'bin/rake assets:precompile'
            execute 'rm -f public/assets.7z'
            execute 'cd public && 7z a assets.7z assets && cd ..'
            execute 'rm -rf public/assets'
          end
        end

        within release_path do
          with rails_env: fetch(:rails_env) do
            old_manifest_path = "#{shared_path}/public/assets/manifest*"
            execute "rm -rf #{old_manifest_path}"
#            execute :rm, old_manifest_path if test "[ -f #{old_manifest_path} ]"
            upload!('./public/assets.7z', "#{shared_path}/public/assets.7z", recursive: false)
          end
        end

        run_locally do
          execute 'rm -f public/assets.7z'
        end

        execute "rm -rf #{shared_path}/public/assets"
        execute "cd #{shared_path}/public && 7z x assets.7z && cd .."
        execute "rm -f #{shared_path}/public/assets.7z"
      end
    end
  end
end
