require File.dirname(__FILE__) + "/../test_helper"

class TestGitWorkingCopyGuessing < Test::Unit::TestCase
  def setup
    @dir = Pathname.new("tmp/wc")
  end

  def test_does_git_status_on_directory
    Piston::Git::WorkingCopy.expects(:git).with(:status, @dir).returns("# On branch master
nothing to commit (working directory clean)
")
    assert Piston::Git::WorkingCopy.understands_dir?(@dir)
  end

  def test_does_git_status_on_parent_directories_recursively
    @wc = @dir
    @tmp = @wc.parent
    @root = @tmp.parent
    Piston::Git::WorkingCopy.expects(:git).with(:status, @wc)
    Piston::Git::WorkingCopy.expects(:git).with(:status, @tmp)
    Piston::Git::WorkingCopy.expects(:git).with(:status, @root).returns("# On branch master
nothing to commit (working directory clean)
")
    assert Piston::Git::WorkingCopy.understands_dir?(@dir)
  end

  def test_denies_when_git_unavailable
    Piston::Git::WorkingCopy.stubs(:git).raises(Piston::Git::Client::BadCommand)
    deny Piston::Git::WorkingCopy.understands_dir?(@dir)
  end
end
