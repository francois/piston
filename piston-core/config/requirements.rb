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

$:.unshift(File.join(File.dirname(__FILE__), %w[.. lib]))

require "piston_core"
require "piston_core/repository"
require "piston_core/revision"
require "piston_core/working_copy"

require "piston_core/commands/base"
require "piston_core/commands/import"
