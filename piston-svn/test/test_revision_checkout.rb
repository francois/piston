require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestRevisionCheckout < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @repos = mock("repository")
    @repos.stubs(:url).returns("http://a.repos.com/trunk")
  end

  def test_head_checkout_to_path
    rev = new_revision("HEAD")
    rev.expects(:svn).with(:checkout, "--quiet", "--revision", "HEAD", @wcdir).returns("Checked out revision 1322.")
    rev.checkout_to(@wcdir)
    assert_equal 1322, rev.revision
  end

  def test_specific_revision_checkout_to_path
    rev = new_revision(1231)
    rev.expects(:svn).with(:checkout, "--quiet", "--revision", 1231, @wcdir).returns("Checked out revision 1231.")
    rev.checkout_to(@wcdir)
  end

  private
  def new_revision(revision)
    Piston::Svn::Revision.new(@repos, revision)
  end
end
