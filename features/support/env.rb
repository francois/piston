require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support
require "pathname"
require "fileutils"
require File.dirname(__FILE__) + "/svn"
require File.dirname(__FILE__) + "/git"
require "spec"

class Tmpdir
  def self.where(subpath=nil)
    @tmpdir ||= Pathname.new(ENV["TMPDIR"] || ENV["TMP"] || "tmp") + "piston"
    @tmpdir + subpath.to_s
  end

  def self.piston
    return @piston if @piston
    bin = (Pathname.new(File.dirname(__FILE__)) + "../../bin/piston").realpath
    lib = (Pathname.new(File.dirname(__FILE__)) + "../../lib").realpath
    @piston = "ruby -I #{lib} #{bin}"
  end
end

STDERR.puts "Removing #{Tmpdir.where}" if $DEBUG

Before do
  _ = Tmpdir.piston
  FileUtils.rm_rf(Tmpdir.where, :verbose => $DEBUG)
  Tmpdir.where.mkpath
end
