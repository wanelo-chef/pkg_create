#
# Cookbook Name:: pkg_create
# Recipe:: lz4c
#
# Copyright:: Wanelo, Inc.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "paths"

install_dir = node['paths']['bin_dir']
build_dir = "#{Chef::Config[:file_cache_path]}/lz4c"
package_dir = "#{Chef::Config[:file_cache_path]}/lz4c-package"

# Generate package information for lz4c
directory package_dir do
  mode 0755
end

execute "build packlist file for lz4c" do
  command "echo 'lz4c' > #{package_dir}/packlist"
end

execute "build build-info file for lz4c" do
  command "pkg_info -X pkg_install | egrep '^(MACHINE_ARCH|OPSYS|OS_VERSION|PKGTOOLS_VERSION)' > #{package_dir}/build-info"
end

execute "build comment file for lz4c" do
  command "echo 'Package that installs lz4c' > #{package_dir}/comment"
end

template "#{package_dir}/description" do
  source 'lz4c_description.erb'
end

# Build lz4c
git build_dir do
  repository "https://github.com/juntalis/lz4-mirror.git"
  reference "master"
  action :sync
  notifies :run, "execute[build lz4c]"
end

execute "build lz4c" do
  command "cd #{build_dir} && make EXT=''"
  action :nothing
  notifies :run, "execute[build lz4c package]"
end

# Create package
execute "build lz4c package" do
  command "pkg_create -B #{package_dir}/build-info -c #{package_dir}/comment " +
          "-d #{package_dir}/description -f #{package_dir}/packlist "+
          "-I #{install_dir} -p #{build_dir} " +
          "-U #{node['pkg_create']['packages_dir']}/lz4c-104.tgz"
  only_if "ls #{build_dir}/lz4c"
  action :nothing
end

include_recipe "pkg_create::default"
