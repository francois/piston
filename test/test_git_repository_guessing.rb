require File.dirname(__FILE__) + "/test_helper"

class TestGitRepositoryGuessing < Test::Unit::TestCase
  def test_understands_git_protocol
    assert PistonGit::Repository.understands_url?("git://github.com/francois/piston.git")
  end

  def test_understand_http_when_heads_returned
    PistonGit::Repository.expects(:git).with("ls-remote", "--heads", "http://github.com/francois/piston.git").returns("ab"*20 + " refs/heads/master")
    assert PistonGit::Repository.understands_url?("http://github.com/francois/piston.git")
  end

  def test_does_not_understand_http_when_no_heads
    PistonGit::Repository.expects(:git).with("ls-remote", "--heads", "http://github.com/francois/piston.git").returns("")
    deny PistonGit::Repository.understands_url?("http://github.com/francois/piston.git")
  end

  def test_asks_url_when_ssh_protocol
    PistonGit::Repository.expects(:git).with("ls-remote", "--heads", "ssh://francois@github.com/francois/piston.git").returns("ab"*20 + " refs/heads/master")
    assert PistonGit::Repository.understands_url?("ssh://francois@github.com/francois/piston.git")
  end
end
