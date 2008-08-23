#!/usr/bin/env ruby
#
# Import a Git project into a Subversion working copy.
require "#{File.dirname(__FILE__)}/common"

@root = @root + "tmp/git_svn"
@root.rmtree rescue nil
@root.mkpath

@repos = @root + "repos"
@wc = @root + "wc"

@plugin = @root + "plugin"
@tmp = @root + "plugin.tmp"

svnadmin :create, @repos
svn :checkout, "--quiet", "file://" + @repos.realpath, @wc

@plugin.mkpath
File.open(@plugin + "README", "wb") {|f| f.puts "Hello World"}
File.open(@plugin + "init.rb", "wb") {|f| f.puts "# Some initialization code here"}
Dir.chdir(@plugin) do
  logger.debug {"CWD: #{Dir.getwd}"}
  git :init
  git :add, "."
  git :commit, "-m", "initial commit"
end

repos = Piston::Git::Repository.new("file://" + @plugin.realpath)
commit = repos.at(:head)
commit.checkout_to(@tmp)
wc = Piston::Svn::WorkingCopy.new(@wc + "vendor")
wc.create
wc.copy_from(commit)
wc.remember(commit.remember_values)
wc.finalize
