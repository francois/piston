require File.dirname(__FILE__) + "/test_helper"

class TestGitWorkingCopyCreation < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wcdir.rmtree rescue nil
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
    @wc.stubs(:git)
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_create_does_a_simple_mkdir
    @wcdir.expects(:mkdir)
    @wc.create
  end

  def test_create_succeeds_even_if_mkdir_fails
    @wcdir.expects(:mkdir).raises(Errno::EEXIST)
    assert_nothing_raised do
      @wc.create
    end
  end
end
