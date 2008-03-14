require "fileutils"
include FileUtils

require "rubygems"
%w[rake hoe newgem rubigen].each do |req_gem|
  begin
    require req_gem
  rescue LoadError
    puts "This Rakefile requires the '#{req_gem}' RubyGem."
    puts "Installation: gem install #{req_gem} -y"
    exit
  end
end

# general
require "pathname"

PISTON_GIT_ROOT = Pathname.new(File.dirname(__FILE__)).parent.realpath
PISTON_CORE_ROOT = PISTON_GIT_ROOT.parent + "piston-core"
$:.unshift(PISTON_CORE_ROOT + "lib") if PISTON_CORE_ROOT.directory?
$:.unshift(PISTON_GIT_ROOT + "lib")

# piston-core
require "piston_core/repository"
require "piston_core/revision"
require "piston_core/working_copy"

# piston-git
require "piston_git"
