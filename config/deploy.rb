set :user, 'tekniklr'                 # Your dreamhost account's username
set :domain, 'ps14010.dreamhost.com'  # Dreamhost servername where your account is located 
set :project, 'tekniklr.com'          # Your application as its called in the repository
set :application, 'new.tekniklr.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{user}/rails.tekniklr.com"
set :rails_env, 'production'

# version control config
set :scm, :git
set :repository,  "git@github.com:tekniklr/tekniklr.com.git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_via, :remote_cache
set :copy_compression, :bz2

role :web, domain
role :app, domain
role :db,  domain, :primary => true   # Where migrations will run

# deploy config
set :deploy_to, applicationdir

# additional settings
default_run_options[:pty] = false
ssh_options[:forward_agent] = true
set :use_sudo, false
set :keep_releases, 3