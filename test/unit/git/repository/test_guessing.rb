require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitRepositoryGuessing < Piston::TestCase
  def test_understands_git_protocol
    assert Piston::Git::Repository.understands_url?("git://github.com/francois/piston.git")
  end

  def test_understands_git_ssh_protocol
    Piston::Git::Repository.expects(:git).with("ls-remote", "--heads", "git@github.com:francois/piston.git").returns("ab"*20 + " refs/heads/master")
    assert Piston::Git::Repository.understands_url?("git@github.com:francois/piston.git")
  end

  def test_understand_http_when_heads_returned
    Piston::Git::Repository.expects(:git).with("ls-remote", "--heads", "http://github.com/francois/piston.git").returns("ab"*20 + " refs/heads/master")
    assert Piston::Git::Repository.understands_url?("http://github.com/francois/piston.git")
  end

  def test_does_not_understand_http_when_no_heads
    Piston::Git::Repository.expects(:git).with("ls-remote", "--heads", "http://github.com/francois/piston.git").returns("")
    deny Piston::Git::Repository.understands_url?("http://github.com/francois/piston.git")
  end

  def test_asks_url_when_ssh_protocol
    Piston::Git::Repository.expects(:git).with("ls-remote", "--heads", "ssh://francois@github.com/francois/piston.git").returns("ab"*20 + " refs/heads/master")
    assert Piston::Git::Repository.understands_url?("ssh://francois@github.com/francois/piston.git")
  end

  def test_asks_base_url_when_named_branch_in_url
    Piston::Git::Repository.expects(:git).with("ls-remote", "--heads", "ssh://francois@github.com/francois/piston.git").returns("ab"*20 + " refs/heads/master")
    assert Piston::Git::Repository.understands_url?("ssh://francois@github.com/francois/piston.git?convert")
  end
end
