require File.dirname(__FILE__) + "/../../../test_helper"

class TestSvnRevisionCheckout < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @repos = mock("repository")
    @repos.stubs(:url).returns("http://a.repos.com/trunk")
  end

  def test_head_checkout_to_path
    rev = new_revision("HEAD")
    rev.expects(:svn).with(:checkout, "--revision", "HEAD", @repos.url, @wcdir).returns("Checked out revision 1322.")
    rev.checkout_to(@wcdir)
    assert_equal 1322, rev.revision
  end

  def test_specific_revision_checkout_to_path
    rev = new_revision(1231)
    rev.expects(:svn).with(:checkout, "--revision", 1231, @repos.url, @wcdir).returns("Checked out revision 1231.")
    rev.checkout_to(@wcdir)
  end

  private
  def new_revision(revision)
    Piston::Svn::Revision.new(@repos, revision)
  end
end
