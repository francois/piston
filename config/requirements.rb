require "fileutils"
include FileUtils

require "rubygems"
%w[rake hoe newgem rubigen mocha activesupport log4r].each do |req_gem|
  begin
    require req_gem
  rescue LoadError
    puts "This Rakefile requires the '#{req_gem}' RubyGem."
    puts "Installation: gem install #{req_gem} -y"
    exit
  end
end

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib])))

require "piston"
require "piston/commands"
