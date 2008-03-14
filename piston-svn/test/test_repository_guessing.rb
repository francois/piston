require File.dirname(__FILE__) + "/test_helper"

class TestRepositoryGuessing < Test::Unit::TestCase
  def test_guesses_with_svn_protocol
    assert PistonSvn::Repository.understands_url?("svn://a.host.com/")
  end

  def test_guesses_with_svn_plus_bla_protocol
    assert PistonSvn::Repository.understands_url?("svn+bla://username@a.host.com/")
  end

  def test_guesses_with_svn_plus_ssh_protocol
    assert PistonSvn::Repository.understands_url?("svn+ssh://username@a.host.com/")
  end

  def test_contacts_repository_for_file_protocol
    url = "file:///home/username/svn/projects/trunk"
    PistonSvn::Repository.expects(:svn).with(:info, url).returns("Repository UUID: abcdef\n")
    assert PistonSvn::Repository.understands_url?(url)
  end

  def test_contacts_repository_for_http_protocol
    url = "http://svn.collab.net/repos/svn/trunk"
    PistonSvn::Repository.expects(:svn).with(:info, url).returns("Repository UUID: abcdef\n")
    assert PistonSvn::Repository.understands_url?(url)
  end

  def test_says_does_not_understand_when_svn_info_errors_out
    url = "http://rubyonrails.org/"
    PistonSvn::Repository.expects(:svn).with(:info, url).raises(PistonSvn::Client::Failed)
    deny PistonSvn::Repository.understands_url?(url)
  end

  def test_says_does_not_understand_when_svn_command_not_found
    url = "http://rubyonrails.org/"
    PistonSvn::Repository.expects(:svn).with(:info, url).raises(PistonSvn::Client::BadCommand)
    deny PistonSvn::Repository.understands_url?(url)
  end
end
