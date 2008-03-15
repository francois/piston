require File.dirname(__FILE__) + "/test_helper"

class TestCommitRememberValues < Test::Unit::TestCase
  def setup
    @repos = mock("repository")
    @repos.stubs(:url).returns("git://github.com/francois/arepos.git")

    @reposdir = Pathname.new("tmp/repos.git")
    @commit = PistonGit::Commit.new(@repos, "ab"*20)
    @values = @commit.remember_values
  end

  def test_remembers_original_repository_url
    assert_equal @repos.url, @values[PistonGit::URL]
  end

  def test_remembers_original_commit
    assert_equal @values[PistonGit::COMMIT], @commit.commit
  end
end
