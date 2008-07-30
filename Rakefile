# Jabber::Simple - Ruby Helper for Faking Web Requests
# Copyright 2006 Blaine Cook <romeda@gmail.com>.
# 
# Jabber::Simple is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# Jabber::Simple is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Jabber::Simple; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

desc "Package Gem"
task :package do
  system('gem build xmpp4r-simple.gemspec')
end

desc "Default Task"
task :default => [:tests]

desc "Run All Tests"
Rake::TestTask.new :tests do |test|
  test.test_files = ["test/**/*.rb"]
  test.verbose = true
end

desc "Generate Documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.main = "README"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README", "COPYING", "lib/*.rb")
  rdoc.title = "Jabber::Simple"
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/**/test*.rb'] 
  t.rcov_opts << "--sort coverage"
end
