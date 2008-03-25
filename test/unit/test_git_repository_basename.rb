require File.dirname(__FILE__) + "/../test_helper"

class TestGitRepositoryBasename < Test::Unit::TestCase
  def test_basename_is_urls_last_component_minus_dot_git
    assert_equal "piston", basename("git://github.com/francois/piston.git")
  end

  private
  def basename(url)
    Piston::Git::Repository.new(url).basename
  end
end
