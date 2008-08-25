require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestMerging < Piston::TestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @repos = mock("repository")
    @repos.stubs(:url).returns("git://github.com/technoweenie/attachment_fu.git")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)

    @from  = mock("fromrevision")
    @to    = mock("torevision")
    @todir = @wcdir + "/.vendor"
  end
end
