require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestRevisionCheckout < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @repos = mock("repository")
  end

  def test_head_checkout_to_path
    rev = new_revision("HEAD")
    rev.expects(:svn).with(:checkout, "--quiet", "--revision", "HEAD", @wcdir)
    rev.checkout_to(@wcdir)
  end

  def test_specific_revision_checkout_to_path
    rev = new_revision(1231)
    rev.expects(:svn).with(:checkout, "--quiet", "--revision", 1231, @wcdir)
    rev.checkout_to(@wcdir)
  end

  private
  def new_revision(revision)
    Piston::Svn::Revision.new(@repos, revision)
  end
end
