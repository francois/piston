require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyCopying < Test::Unit::TestCase
  include Piston::Svn::Client

  def setup
    @reposdir = Pathname.new("tmp/repos")
    svnadmin :create, @reposdir

    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def teardown
    @reposdir.rmtree rescue nil
    @wcdir.rmtree rescue nil
  end

  def test_copies_files
    files = ["file.rb"]
    files.expects(:copy_to).with(@wcdir + files.first)
    @wc.copy_from(files)
  end

  def test_ensures_directories_are_created
    files = ["file/a.rb"]
    @wcdir.expects(:+).with(files.first).returns(target = mock("target"))
    target.expects(:dirname).returns(target)
    target.expects(:mkdir)
    files.expects(:copy_to).with(target)
    @wc.copy_from(files)
  end
end
