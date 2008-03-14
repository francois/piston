require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyCreation < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = PistonSvn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_create_uses_svn_mkdir
    @wc.expects(:svn).with(:mkdir, @wcdir)
    @wc.create
  end

  def test_create_sets_local_revision
    @wc.expects(:svn).with(:info, @wcdir.parent).returns("Last Changed Rev: 1321\n")
    @wc.expects(:svn).with(:propset, PistonSvn::LOCAL_REV, 1321, @wcdir)
    @wc.create
  end
end
