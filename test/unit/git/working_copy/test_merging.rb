require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class TestMerging < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wcdir.mkdir rescue nil
    @repos = mock("repository")
    @repos.stubs(:url).returns("git://github.com/technoweenie/attachment_fu.git")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)

    @from  = mock("fromrevision")
    @to    = mock("torevision")
    @todir = @wcdir + "/.vendor"
  end
end
