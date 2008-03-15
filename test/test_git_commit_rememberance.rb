require File.dirname(__FILE__) + "/test_helper"

class TestGitCommitRememberance < Test::Unit::TestCase
  def setup
    @repos = mock("repository")
    @repos.stubs(:url).returns("git://github.com/francois/arepos.git")

    @reposdir = Pathname.new("tmp/repos.git")
    @commit = Piston::Git::Commit.new(@repos, "ab"*20)
    @values = @commit.remember_values
  end

  def test_remembers_original_repository_url
    assert_equal @repos.url, @values[Piston::Git::URL]
  end

  def test_remembers_original_commit
    assert_equal @values[Piston::Git::COMMIT], @commit.commit
  end
end
