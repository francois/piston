require File.dirname(__FILE__) + "/test_helper"

class TestGitRepositoryAt < Test::Unit::TestCase
  def setup
    @repos = Piston::Git::Repository.new("git://a.repos.com/project.git")
  end

  def test_returns_a_piston_git_commit
    Piston::Git::Commit.expects(:new).with(@repos, "a93029").returns(commit = mock("commit"))
    assert_equal commit, @repos.at("a93029")
  end
end
