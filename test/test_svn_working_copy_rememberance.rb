require File.dirname(__FILE__) + "/test_helper"

class TestSvnWorkingCopyRememberance < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wcdir.mkpath
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

end
