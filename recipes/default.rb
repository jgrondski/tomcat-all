#
# Cookbook Name:: tomcat-all
# Recipe:: default
#
# Copyright (C) 2014 Roberto Moutinho
#
# All rights reserved - Do Not Redistribute
#

# Build download URL
tomcat_version = node['tomcat-all']['version']
major_version = tomcat_version[0]
download_url = "http://archive.apache.org/dist/tomcat/tomcat-#{major_version}/v#{tomcat_version}/bin/apache-tomcat-#{tomcat_version}.tar.gz"

# Create group
group node['tomcat-all']['group']

# Create user
user node['tomcat-all']['user'] do
  supports :manage_home => true
  group node['tomcat-all']['group']
  system true
  home '/home/tomcat'
  shell '/bin/bash'
end

# Download and unpack tomcat
ark 'tomcat' do
  url download_url
  version node['tomcat-all']['version']
  prefix_root node['tomcat-all']['install_directory']
  prefix_home node['tomcat-all']['install_directory']
  owner node['tomcat-all']['user']
  notifies :create, 'template[/etc/systemd/system/tomcat.service]', :immediately
end

# Tomcat init script configuration
template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  mode '0755'
  action :nothing
end

include_recipe 'tomcat-all::set_tomcat_home'

# Enabling tomcat service and starting
service 'tomcat' do
  action [:enable, :start]
end
