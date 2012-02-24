# Sets up a private git repository.  Given a usage like
#
#  git_private_repo 'apeyeye' do
#    repository 'git@github.com:infochimps/apeyeye.git'
#    path       '/var/www/apeyeye'
#  end
#
# Both `path' and `repository' are required and, it seems, repository
# must be an SSH style URI above, not a git:// style.
#
# It is expected that the SSH public key 'apeyeye.pub' and the
# corresponding private key 'apeyeye.pem' exist as files in the
# calling cookbook.
#
# Shared deploy keys can be created and placed in
# 'shared_deploy_key.pub' and 'shared_deploy_key.pem' in the files
# directory of the git cookbook.  These can be used by passing
# `shared_keys true' to the above resource.
#
# `user' and `group' can be passed and they'll set the user and group
# of the resulting repository (the keys &c. cannot be changed this
# way).
#
# You can also pass the :ssh_wrapper action to have the keys and the
# wrapper script be created but the repository not cloned (useful in
# deploy resources).  The wrapper script will be at
# etc/deploy/#{params[:name}/#{params[:name]}.sh
define :git_private_repo, :action => :checkout, :repository => nil, :shared_keys => nil, :path => nil, :user => nil, :group => nil, :branch => 'deploy', :enable_submodules => false do

  deploy_dir       = File.join('/etc/deploy', params[:name])
  private_key_path = File.join(deploy_dir, "#{params[:name]}.pem")
  public_key_path  = File.join(deploy_dir, "#{params[:name]}.pub")
  ssh_wrapper_path = File.join(deploy_dir, "#{params[:name]}.sh")

  directory deploy_dir do
    group 'admin'
    mode 0750
    action :create
    recursive true
  end

  cookbook_file private_key_path do
    if params[:shared_keys]
      cookbook 'git'
      source "shared_deploy_key.pem"
    else
      source File.basename(private_key_path)
    end
    group 'admin'
    mode 0600
    action :create
  end

  cookbook_file public_key_path do
    if params[:shared_keys]
      cookbook 'git'
      source "shared_deploy_key.pub"
    else
      source File.basename(public_key_path)
    end
    group 'admin'
    mode 0644
    action :create
  end

  template ssh_wrapper_path do
    variables :private_key_path => private_key_path
    source "ssh_wrapper.sh.erb"
    cookbook 'git'
    group 'admin'
    mode 0776
    action :create
  end

  unless params[:action] == :ssh_wrapper

    directory File.dirname(params[:path]) do
      if params[:group]
        group params[:group]
      end
      mode 0755
      action :create
      recursive true
    end
    
    git params[:path] do
      ssh_wrapper ssh_wrapper_path
      repository  params[:repository]
      branch      params[:branch]
      if params[:user]
        user params[:user]
      end
      if params[:group]
        group       params[:group]
      end
      action      params[:action]
      enable_submodules params[:enable_submodules]
    end
  end
  
end
  


