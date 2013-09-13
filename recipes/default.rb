#
# Cookbook Name:: pkg_create
# Recipe:: default
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

directory "#{node['pkg_create']['packages_dir']}" do
  action :create
end

bash "rebuild package definitions" do
  user "root"
  code <<-EOH
  for pkg in $(ls *.tgz #{node['pkg_create']['packages_dir']}); do \
  pkg_info -X $pkg; done | gzip -9 > #{node['pkg_create']['packages_dir']}/pkg_summary.gz
  EOH
end
