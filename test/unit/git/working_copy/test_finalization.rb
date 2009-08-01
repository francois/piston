require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitWorkingCopyFinalization < Piston::TestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
  end

  def test_finalize_adds_path_to_git
    Dir.expects(:chdir).with(@wcdir).yields
    @wc.expects(:git).with(:add, "--force", ".")
    @wc.finalize
  end
end
