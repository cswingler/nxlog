#
# Cookbook Name:: nxlog_ce
# Recipe:: default
#
# Copyright (C) 2014 Simon Detheridge
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'debian'
  if node['platform'] == 'ubuntu'
    include_recipe 'nxlog_ce::ubuntu'
  else
    include_recipe 'nxlog_ce::debian'
  end
when 'rhel'
  include_recipe 'nxlog_ce::redhat'
when 'windows'
  include_recipe 'nxlog_ce::windows'
else
  Chef::Application.fatal!('Attempted to install on an unsupported platform')
end

package_name = node['nxlog_ce']['installer_package']

remote_file 'nxlog_ce' do
  path "#{Chef::Config[:file_cache_path]}/#{package_name}"
  source "http://nxlog.org/system/files/products/files/1/#{package_name}"
  mode 0644
end

if platform?('ubuntu', 'debian')
  dpkg_package 'nxlog_ce' do
    source "#{Chef::Config[:file_cache_path]}/#{package_name}"
  end
else
  package 'nxlog_ce' do
    source "#{Chef::Config[:file_cache_path]}/#{package_name}"
  end
end

service 'nxlog' do
  action [:enable, :start]
end

template "#{node['nxlog_ce']['conf_dir']}/nxlog.conf" do
  source 'nxlog.conf.erb'

  notifies :restart, 'service[nxlog]', :delayed
end

directory "#{node['nxlog_ce']['conf_dir']}/nxlog.conf.d"
