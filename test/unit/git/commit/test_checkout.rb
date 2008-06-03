require File.dirname(__FILE__) + "/../../../test_helper"

class TestGitCommitCheckout < Test::Unit::TestCase
  def setup
    @repos = mock("repos")
    @repos.stubs(:url).returns("git://a.repos.com/project.git")
    @reposdir = Pathname.new("tmp/.repos.tmp.git")
  end

  def test_clones_repository_at_indicated_path
    @sha1 = "a9302"
    @commit = Piston::Git::Commit.new(@repos, @sha1)
    @commit.expects(:git).with(:clone, @repos.url, @reposdir)
    @commit.expects(:git).with(:checkout, "-b", "my-#{@sha1}", @sha1)
    @commit.expects(:git).with(:log, "-n", "1").returns("commit 922b12a6bcbb6f6a2cec60bcf5de17118086080a\nAuthor: Fran\303\247ois Beausoleil <francois@teksol.info>\nDate:   Fri Mar 14 13:28:41 2008 -0400\n\n    Changed how dependencies are found and managed, by using config/requirements.rb everywhere.\n    \n    Updated test/test_helper.rb where appropriate.\n")
    Dir.expects(:chdir).with(@reposdir).yields
    @commit.checkout_to(@reposdir)
  end

  def test_cloning_head_finds_head_commit
    @sha1 = "HEAD"
    @commit = Piston::Git::Commit.new(@repos, @sha1)
    @commit.expects(:git).with(:clone, @repos.url, @reposdir)
    @commit.expects(:git).with(:checkout, "-b", "my-#{@sha1}", @sha1)
    @commit.expects(:git).with(:log, "-n", "1").returns("commit 922b12a6bcbb6f6a2cec60bcf5de17118086080a\nAuthor: Fran\303\247ois Beausoleil <francois@teksol.info>\nDate:   Fri Mar 14 13:28:41 2008 -0400\n\n    Changed how dependencies are found and managed, by using config/requirements.rb everywhere.\n    \n    Updated test/test_helper.rb where appropriate.\n")
    Dir.expects(:chdir).with(@reposdir).yields
    @commit.checkout_to(@reposdir)
    assert_equal "922b12a6bcbb6f6a2cec60bcf5de17118086080a", @commit.revision
  end
end
