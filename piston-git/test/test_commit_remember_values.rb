require File.dirname(__FILE__) + "/test_helper"

class TestCommitRememberValues < Test::Unit::TestCase
  def setup
    @commit = PistonGit::Commit.new(@repos, :head)
    @values = @commit.remember_values
  end

  def test_remembers_original_repository_url
    flunk
  end
end
