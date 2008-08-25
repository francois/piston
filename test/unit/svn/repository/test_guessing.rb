require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestSvnRepositoryGuessing < Piston::TestCase
  def test_guesses_with_svn_protocol
    assert Piston::Svn::Repository.understands_url?("svn://a.host.com/")
  end

  def test_guesses_with_svn_plus_bla_protocol
    assert Piston::Svn::Repository.understands_url?("svn+bla://username@a.host.com/")
  end

  def test_guesses_with_svn_plus_ssh_protocol
    assert Piston::Svn::Repository.understands_url?("svn+ssh://username@a.host.com/")
  end

  def test_contacts_repository_for_file_protocol
    url = "file:///home/username/svn/projects/trunk"
    Piston::Svn::Repository.expects(:svn).with(:info, url).returns("Repository UUID: abcdef\n")
    assert Piston::Svn::Repository.understands_url?(url)
  end

  def test_contacts_repository_for_http_protocol
    url = "http://svn.collab.net/repos/svn/trunk"
    Piston::Svn::Repository.expects(:svn).with(:info, url).returns("Repository UUID: abcdef\n")
    assert Piston::Svn::Repository.understands_url?(url)
  end

  def test_contacts_repository_for_https_protocol
    url = "https://svn.collab.net/repos/svn/trunk"
    Piston::Svn::Repository.expects(:svn).with(:info, url).returns("Repository UUID: abcdef\n")
    assert Piston::Svn::Repository.understands_url?(url)
  end

  def test_says_does_not_understand_when_svn_info_errors_out
    url = "http://rubyonrails.org/"
    Piston::Svn::Repository.expects(:svn).with(:info, url).raises(Piston::Svn::Client::Failed)
    deny Piston::Svn::Repository.understands_url?(url)
  end

  def test_says_does_not_understand_when_svn_command_not_found
    url = "http://rubyonrails.org/"
    Piston::Svn::Repository.expects(:svn).with(:info, url).raises(Piston::Svn::Client::BadCommand)
    deny Piston::Svn::Repository.understands_url?(url)
  end
end
