#!/usr/bin/env ruby
#
# Import an SVN repository into an SVN working copy.
require File.dirname(__FILE__) + "/common"

@root = @root + "tmp/svn_svn"
@root.rmtree rescue nil
@root.mkpath

@repos = @root + "repos"
@wc = @root + "wc"
@tmp = @root + "xlsuite.tmp"

svnadmin :create, @repos
svn :checkout, "file://#{@repos.realpath}", @wc

repos = Piston::Svn::Repository.new("http://svn.xlsuite.org/trunk/lib")
rev = repos.at(:head)
rev.checkout_to(@tmp)
wc = Piston::Svn::WorkingCopy.new(@wc + "tmp")
wc.create
wc.copy_from(rev)
wc.remember(rev.remember_values)
wc.finalize
