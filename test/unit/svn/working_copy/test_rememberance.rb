require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

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

  def test_after_remember_adds_path_using_svn
    @wc.expects(:svn).with(:info, :the_path).returns("a: (Not a versioned resource)\n")
    @wc.expects(:svn).with(:add, :the_path)
    @wc.after_remember(:the_path)
  end

  def test_after_remember_does_not_add_if_file_already_under_version_control
    @wc.expects(:svn).with(:info, :the_path).returns("a: b\n")
    @wc.after_remember(:the_path)
  end
end
