#!/usr/bin/env ruby
#
# Import an SVN repository into a Git working copy.
require File.dirname(__FILE__) + "/common"

@root = @root + "tmp/svn_git"
@root.rmtree rescue nil
@root.mkpath

@repos = @root + "repos"
@wc = @root + "wc"
@tmp = @root + "xlsuite.tmp"

@wc.mkpath
File.open(@wc + "README", "wb") {|f| f.write "Hello World"}
Dir.chdir(@wc) do
  git :init
  git :add, "."
  git :commit, "-m", "initial"
end

repos = Piston::Svn::Repository.new("http://svn.xlsuite.org/trunk/lib")
rev = repos.at(:head)
rev.checkout_to(@tmp)
wc = Piston::Git::WorkingCopy.new(@wc + "vendor")
wc.create
wc.copy_from(rev)
wc.remember(rev.remember_values)
wc.finalize
