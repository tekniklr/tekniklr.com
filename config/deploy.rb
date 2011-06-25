set :user, 'tekniklr'  # Your dreamhost account's username
set :domain, 'ps14010.dreamhost.com'  # Dreamhost servername where your account is located 
set :project, 'tekniklr.com'  # Your application as its called in the repository
set :application, 'new.tekniklr.com'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{user}/rails.tekniklr.com"  # The standard Dreamhost setup

# version control config
set :scm, :git
set :repository,  "git@github.com:tekniklr/tekniklr.com.git"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1 # if you have vendored rails
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_via, :remote_cache

role :web, domain
role :app, domain
role :db,  domain, :primary => true

# deploy config
set :deploy_to, applicationdir
set :deploy_via, :export

# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
ssh_options[:forward_agent] = true
#ssh_options[:keys] = %w(/home/tekniklr/.ssh/id_rsa) # If you are using ssh_keys
set :chmod755, "app config db lib public vendor script script/* public/disp*"
set :use_sudo, false