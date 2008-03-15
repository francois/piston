#!/usr/bin/env ruby
#
# Import an SVN repository into a Git working copy.
require File.dirname(__FILE__) + "/common"

(@root + "tmp/repos").rmtree rescue nil
(@root + "tmp/wc").rmtree rescue nil
(@root + "tmp/.xlsuite.tmp").rmtree rescue nil

(@root + "tmp/wc").mkpath
File.open(@root + "tmp/wc/README", "wb") {|f| f.write "Hello World"}
Dir.chdir(@root + "tmp/wc") do
  git :init
  git :add, "."
  git :commit, "-m", "initial"
end

repos = Piston::Svn::Repository.new("http://svn.xlsuite.org/trunk/lib")
rev = repos.at(:head)
rev.checkout_to(@root + "tmp/.xlsuite.tmp")
wc = Piston::Git::WorkingCopy.new(@root + "tmp/wc/vendor")
wc.create
wc.copy_from(rev)
wc.remember(rev.remember_values)
wc.finalize
