require File.dirname(__FILE__) + "/test_helper"

class TestGitWorkingCopyFinalization < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_finalize_adds_path_to_git
    @wc.expects(:git).with(:add, @wcdir)
    @wc.finalize
  end
end
