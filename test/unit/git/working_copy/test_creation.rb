require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitWorkingCopyCreation < Piston::TestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
    @wc.stubs(:git)
  end

  def test_create_does_a_simple_mkpath
    @wcdir.expects(:mkpath)
    @wc.create
  end

  def test_create_succeeds_even_if_mkpath_fails
    @wcdir.expects(:mkpath).raises(Errno::EEXIST)
    assert_nothing_raised do
      @wc.create
    end
  end
end
