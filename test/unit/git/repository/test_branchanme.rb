require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitRepositoryBranchname < PistonTestCase
  def test_branchname_is_nil_when_no_branch_in_url
    assert_nil Piston::Git::Repository.new("git://github.com/francois/piston.git").branchname
  end

  def test_branchname_is_branch_when_branch_in_url
    assert_equal "branch", Piston::Git::Repository.new("git://github.com/francois/piston.git?branch").branchname
  end

  def test_url_does_not_include_branchname
    assert_equal "git://github.com/francois/piston.git", Piston::Git::Repository.new("git://github.com/francois/piston.git?branch").url
  end
end
