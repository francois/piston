require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestSvnRevisionEach < PistonTestCase
  def setup
    super
    @repos = mock("repository")
    @repos.stubs(:url).returns("http://a.repos.com/project/trunk")

    @wcdir = Pathname.new("tmp/.wc.tmp")

    @rev = Piston::Svn::Revision.new(@repos, "HEAD")
    @rev.stubs(:svn).returns("Checked out revision 111.\n")
    @rev.checkout_to(@wcdir)
  end

  def test_each_skips_over_svn_metadata_folders
    @rev.expects(:svn).with(:ls, "--recursive", @wcdir).returns("CONTRIBUTORS\nREADME\ntest/test_helper.rb\n")
    expected = ["CONTRIBUTORS", "README", "test/test_helper.rb"]
    actual = @rev.inject([]) {|memo, relpath| memo << relpath}
    assert_equal expected.sort, actual.sort
  end
end
