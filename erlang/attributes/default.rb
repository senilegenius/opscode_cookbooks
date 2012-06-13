default[:erlang][:gui_tools] = false

case node[:platform]
when "redhat", "centos", "scientific"
  version = node[:platform_version].to_f
  case 
  when ( ( version >= 5.0 ) and ( version < 6.0 ) )
    node[:erlang][:yum_repo] = 'http://repos.fedorapeople.org/repos/peter/erlang/epel-5Server/$basearch'
  when ( version >= 6.0 )
    node[:erlang][:yum_repo] = 'http://download.opensuse.org/repositories/home:/scalaris/CentOS_6/'
  else
    Chef::Log.warn("No yum repo defined: erlang install may fail")
  end
end