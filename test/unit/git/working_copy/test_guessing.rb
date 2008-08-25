require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitWorkingCopyGuessing < PistonTestCase
  def setup
    super
    @dir = mkpath("tmp/wc")
  end

  def test_does_git_status_on_directory
    Dir.expects(:chdir).with(@dir).yields
    Piston::Git::WorkingCopy.expects(:git).with(:status).returns("# On branch master
nothing to commit (working directory clean)
")
    assert Piston::Git::WorkingCopy.understands_dir?(@dir)
  end

  def test_does_git_status_on_parent_directories_recursively
    @wc = @dir
    @tmp = @wc.parent
    @root = @tmp.parent

    Dir.expects(:chdir).with(@dir).raises(Errno::ENOENT)
    Dir.expects(:chdir).with(@tmp).raises(Errno::ENOENT)
    Dir.expects(:chdir).with(@root).yields
    Piston::Git::WorkingCopy.expects(:git).with(:status).returns("# On branch master
nothing to commit (working directory clean)
")
    assert Piston::Git::WorkingCopy.understands_dir?(@dir)
  end

  def test_denies_when_git_unavailable
    Piston::Git::WorkingCopy.stubs(:git).raises(Piston::Git::Client::BadCommand)
    deny Piston::Git::WorkingCopy.understands_dir?(@dir)
  end
end
