require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestSvnRevisionRememberance < PistonTestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @repos = mock("repository")
    @repos.stubs(:url).returns("http://a.repos.com/svn/trunk")

    @info = {"Path" => @wcdir.realpath,
        "URL" => "http://a.repos.com/svn/trunk",
        "Repository Root" => "http://a.repos.com/svn",
        "Repository UUID" => "some-long-uuid",
        "Revision" => "9283",
        "Node Kind" => "directory",
        "Schedule" => "normal",
        "Last Changed Author" => "me",
        "Last Changed Rev" => "9283",
        "Last Changed Date" => "2008-03-11 20:44:24 -0400 (Tue, 11 Mar 2008)"}
  end

  def test_remembers_repos_uuid
    rev = new_revision("HEAD")
    rev.expects(:svn).with(:info, "--revision", "HEAD", @repos.url).returns(@info.to_yaml)
    assert_equal "some-long-uuid", rev.remember_values[Piston::Svn::UUID]
  end

  def test_remembers_repos_revision
    rev = new_revision("HEAD")
    rev.expects(:svn).with(:info, "--revision", "HEAD", @repos.url).returns(@info.to_yaml)
    assert_equal "9283", rev.remember_values[Piston::Svn::REMOTE_REV]
  end

  private
  def new_revision(revision)
    Piston::Svn::Revision.new(@repos, revision)
  end
end
