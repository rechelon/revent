## marked for deletion.  if needed, require "capistrano" gem
#set :default_environment, {
  #'PATH' => "/usr/local/rvm/gems/ree-1.8.7-2010.01/bin:/usr/local/rvm/bin:/usr/local/rvm/rubies/ree-1.8.7-2011.03/bin:$PATH",
  #'RUBY_VERSION' => 'ree-1.8.7-2011.03',
  #'GEM_HOME'     => '/usr/local/rvm/gems/ree-1.8.7-2010.03',
  #'GEM_PATH'     => '/usr/local/rvm/gems/ree-1.8.7-2011.03:/usr/local/rvm/gems/ree-1.8.7-2011.03@global',
  #'BUNDLE_PATH'  => '/usr/local/rvm/gems/ree-1.8.7-2010.03'  # If you are using bundler.
#}

#require "bundler/capistrano"

#set :application, "revent"
#set :repository, "git@github.com:radicaldesigns/#{application}.git"

#set :user, "#{application}"
#set :group, "#{user}"
##set :runner, "#{user}"

#set :deploy_to, "/home/#{user}/#{application}"
#set :scm, :git
#set :keep_releases, 10

#role (:web, 'app1.aflcio.radicaldesigns.org')
#role (:app, 'app1.aflcio.radicaldesigns.org')
#role (:db, 'app1.aflcio.radicaldesigns.org', :primary => true)
## ugly hack to evade caps desire to deploy everywhere without making the multistage jump
##if ARGV[0] =~ /squid/ 
 ## role :squid, "greensquid1.radicaldesigns.org", "greensquid2.radicaldesigns.org", "greensquid3.radicaldesigns.org" 
##end

#set :deploy_via, :remote_cache
#set :git_enable_submodules, 1

#set :use_sudo, true

#after "deploy:update_code", "deploy:symlink_shared"
#after "deploy:symlink_shared", "deploy:after_symlink", "deploy:clear_cache"

#namespace :deploy do
  #desc "Start the server"
  #task :start, :roles => :app do
    #invoke_command "touch #{release_path}/tmp/restart.txt"
  #end

  #desc "Stop the server"
  #task :stop, :roles => :app do
    #invoke_command "touch #{release_path}/tmp/restart.txt"
  #end

  #desc "Restart the server"
  #task :restart, :roles => :app do
    #invoke_command "touch #{release_path}/tmp/restart.txt"
  #end

  #task :symlink_shared, :roles => :app, :except => {:no_symlink => true} do
    #invoke_command "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    #invoke_command "ln -nfs #{shared_path}/config/memcache_config.rb #{release_path}/config/memcache_config.rb"
    #invoke_command "ln -nfs #{shared_path}/config/superusers.yml #{release_path}/config/superusers.yml"
    #invoke_command "ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
    #invoke_command "ln -nfs #{shared_path}/config/cartographer-config.yml #{release_path}/config/cartographer-config.yml"
    #invoke_command "ln -nfs #{shared_path}/config/democracyinaction-config.yml #{release_path}/config/democracyinaction-config.yml"
    #invoke_command "ln -nfs #{shared_path}/config/flickr #{release_path}/config/flickr"
    #invoke_command "ln -nfs #{shared_path}/config/amazon_s3.yml #{release_path}/config/amazon_s3.yml"
    #invoke_command "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    #invoke_command "ln -nfs #{shared_path}/vendor/aws-s3-0.3.0 #{release_path}/vendor/aws-s3-0.3.0"
    #invoke_command "ln -nfs #{shared_path}/vendor/mime-types-1.15 #{release_path}/vendor/mime-types-1.15"
    #invoke_command "ln -nfs #{shared_path}/vendor/rflickr-2006.02.01 #{release_path}/vendor/rflickr-2006.02.01"
    #invoke_command "ln -nfs #{shared_path}/sites #{release_path}/sites"
    #invoke_command "ln -nfs #{shared_path}/config/initializers/hoptoad.rb #{release_path}/config/initializers/hoptoad.rb"
  #end

  #task :after_symlink, :roles => :app , :except => {:no_symlink => true} do
    #invoke_command "ln -nfs #{shared_path}/public/attachments #{release_path}/public/attachments"
    #invoke_command "ln -nfs #{shared_path}/public/cache #{release_path}/public/cache"
    #invoke_command "cd #{release_path} && rake theme_update_cache"
  #end

  #task :clear_cache, :roles =>:app do
    #if ENV['SITE']
      #invoke_command "rm -rf #{shared_path}/public/cache/#{ENV['SITE']}/*"
    #end
  #end
#end


#namespace :db do
  #set :rails_env, "production"

  #desc 'Dumps the production database to db/production_data.sql on the remote server'
  #task :remote_dump, :roles => :db, :only => { :primary => true } do
    #invoke_command "cd #{current_path} && rake RAILS_ENV=#{rails_env} db:dump --trace"
  #end

  #desc 'Downloads db/production_data.sql from the remote production environment to your local machine'
  #task :remote_download, :roles => :db, :only => { :primary => true } do
    #invoke_command "cd #{current_path} && zip db/#{rails_env}_data.zip db/#{rails_env}_data.sql"
    #execute_on_servers(options) do |servers|
      #self.sessions[servers.first].sftp.download! "#{current_path}/db/#{rails_env}_data.zip", "db/#{rails_env}_data.zip"
    #end
    #`unzip db/#{rails_env}_data.zip`
  #end

  #desc 'Cleans up data dump file and zip file'
  #task :remote_cleanup, :roles => :db, :only => { :primary => true } do
    #invoke_command "rm -f #{current_path}/db/#{rails_env}_data.zip"
    #invoke_command "rm -f #{current_path}/db/#{rails_env}_data.sql"
    #File.delete("db/#{rails_env}_data.zip") if File.exists?("db/#{rails_env}_data.zip")
  #end

  #desc 'Dumps, compress, downloads and then cleans up the production data dump'
  #task :remote_runner do
    #remote_dump
    #remote_download
    #remote_cleanup
  #end
#end

#namespace :squid do
  #desc 'clears the squid cache'
  #task :clear_cache, :roles => :squid do
    #set :user, "root"
    #invoke_command "squid -k shutdown; rm -rf /var/spool/squid/*; squid -z;/etc/init.d/squid start"
  #end
#end

