set :application,             "virgin_movies_twitter_bot"

set :domain,                  "slicehost" 
set :deploy_to,               "/home/rupert/virgin_movies"
set :port,                    30465

set :keep_releases,           5

set :scm,                     :git
set :repository,              "git://github.com/rupert/virgin_movies_twitter_bot.git"
set :branch,                  "master"
set :deploy_via,              :remote_cache

set :user,                    "rupert"
set :scm_verbose,             true          # prevent errors with git version < 1.5.5.3

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  # Override finalize_update as it's got Rails specific stuff in it
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
  end

  task :start, :roles => :app do
    # do nothing - not needed for this as it's driven by cron
  end

  task :stop, :roles => :app do
    # do nothing - not needed for this as it's driven by cron
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    # do nothing - not needed for this as it's driven by cron
  end
end

task :update_shared, :roles => [:app] do
  run <<-CMD
  cp -Rf #{shared_path}/config/* #{release_path}/config/ &&
  rm -rf #{release_path}/db &&
  ln -fs #{deploy_to}/#{shared_dir}/db #{release_path}/db
  CMD
end

after "deploy:update_code", :update_shared
