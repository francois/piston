require File.dirname(__FILE__) + "/../../../test_helper"

class TestSvnWorkingCopyCreation < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
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
end
