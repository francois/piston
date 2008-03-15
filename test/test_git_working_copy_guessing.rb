require File.dirname(__FILE__) + "/test_helper"

class TestGitWorkingCopyGuessing < Test::Unit::TestCase
  def setup
    @dir = Pathname.new("tmp/wc")
  end

  def test_does_git_log_on_directory
    Piston::Git::WorkingCopy.expects(:git).with(:log, "-n", "1", @dir).returns("commit " + "a"*40)
    assert Piston::Git::WorkingCopy.understands_dir?(@dir)
  end

  def test_denies_when_git_unavailable
    Piston::Git::WorkingCopy.stubs(:git).raises(Piston::Git::Client::BadCommand)
    deny Piston::Git::WorkingCopy.understands_dir?(@dir)
  end
end
