#!/usr/bin/env ruby
#
# Import an SVN repository into an SVN working copy.
require File.dirname(__FILE__) + "/common"

@root = @root + "tmp/git_git"
@root.rmtree rescue nil
@root.mkpath

@tmp = @root + "plugin.tmp"

@plugin = @root + "plugin"
@plugin.mkpath
File.open(@plugin + "README", "wb") {|f| f.puts "Hello World"}
File.open(@plugin + "init.rb", "wb") {|f| f.puts "# Some init code"}
Dir.chdir(@plugin) do
  git :init
  git :add, "."
  git :commit, "-m", "initial commit"
end

@wc = @root + "wc"
@wc.mkpath
File.open(@wc + "README", "wb") {|f| f.puts "My local project"}
Dir.chdir(@wc) do
  git :init
  git :add, "."
  git :commit, "-m", "initial commit"
end

repos = Piston::Git::Repository.new("file://" + @plugin.realpath)
commit = repos.at(:head)
commit.checkout_to(@tmp)

wc = Piston::Git::WorkingCopy.new(@wc + "vendor")
wc.create
wc.copy_from(commit)
wc.remember(commit.remember_values)
wc.finalize
