require File.dirname(__FILE__) + "/test_helper"

class TestRepositoryAt < Test::Unit::TestCase
  def setup
    @repos = PistonGit::Repository.new("git://a.repos.com/project.git")
  end

  def test_returns_a_piston_git_commit
    PistonGit::Commit.expects(:new).with(@repos, "a93029").returns(commit = mock("commit"))
    assert_equal commit, @repos.at("a93029")
  end
end
