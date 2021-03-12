set :application_name, 'temple'
set :repo_url, proc { "ssh://git@gitlab.tsc.cool:2222/tsc/#{fetch(:application_name)}.git" }
set :deploy_to, proc { "/srv/#{fetch(:application)}" }
set :system_gems, 'bundler'
set :bundle_bins, %w{rake rails}
set :bundle_flags, "--deployment"
set :conditionally_migrate, true
set :format, :pretty
set :log_level, :debug
set :pty, true
set :copy_exclude, [".git/"]
set :keep_assets, 2
set :linked_files, %w{config/database.yml config/puma.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets public/uploads}
set :setup_tasks, %w(gems log_rotate database puma)
set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, ->{ :app }
set :keep_releases, 3
set :rails_env, ->{ fetch(:stage) }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence do
      sudo "/usr/bin/monit restart puma_master"
      sudo "/usr/bin/monit restart sidekiq"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:app), in: :sequence do
      sudo "/usr/bin/monit start puma_master"
      sudo "/usr/bin/monit start sidekiq"
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence do
      sudo "/usr/bin/monit stop puma_master"
      sudo "/usr/bin/monit stop sidekiq"
    end
  end
end

after 'deploy:publishing', 'deploy:restart'
