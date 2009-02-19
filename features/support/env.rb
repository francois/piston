require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support
require "pathname"
require "fileutils"
require File.dirname(__FILE__) + "/svn"

class Tmpdir
  def self.where(subpath=nil)
    @tmpdir ||= Pathname.new(ENV["TMPDIR"] || ENV["TMP"] || "tmp") + "piston"
    @tmpdir.mkpath
    @tmpdir + subpath.to_s
  end
end

puts "Removing #{Tmpdir.where}"
FileUtils.rm_rf(Tmpdir.where, :verbose => true)
