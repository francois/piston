require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestSvnWorkingCopyCreation < PistonTestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def test_create_uses_svn_mkdir
    @wc.expects(:svn).with(:mkdir, @wcdir)
    @wc.create
  end
end
