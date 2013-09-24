#
# Cookbook Name:: pkg_create
# Recipe:: rbenv-ruby-2.0.0-p247
#
# Copyright:: Blake Irvin

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# NOTE: This recipe assumes you have installed system-wide rbenv:
#

source_dir = "/opt/rbenv/versions/2.0.0-p247"
build_dir = "/var/chef/cache/rbenv-ruby-2.0.0-p247"

directory "#{build_dir}" do
  mode 0755
end

execute "build packlist file" do
  command "(cd #{source_dir}; find * -type f -or -type l | sort) > #{build_dir}/packlist"
  only_if "ls #{source_dir}"
end

execute "build build-info file" do
  command "pkg_info -X pkg_install | egrep '^(MACHINE_ARCH|OPSYS|OS_VERSION|PKGTOOLS_VERSION)' > #{build_dir}/build-info"
  only_if "ls #{source_dir}"
end

execute "build comment file" do
  command "echo 'Package that installs ruby-2.0.0-p247 for system-wide rbenv' > #{build_dir}/comment"
  only_if "ls #{source_dir}"
end

template "#{build_dir}/description" do
  source 'rebenv-ruby-2.0.0-p247_description.erb'
  only_if "ls #{source_dir}"
end

directory "#{node['pkg_create']['packages_dir']}" do
  mode 0755
end

execute "build package" do
  command "pkg_create -B #{build_dir}/build-info -c #{build_dir}/comment -d #{build_dir}/description -f #{build_dir}/packlist -I #{source_dir} -p #{source_dir} -U #{node['pkg_create']['packages_dir']}/rbenv-ruby-2.0.0p247.tgz"
  only_if "ls #{source_dir}"
end

include_recipe "pkg_create::default"
