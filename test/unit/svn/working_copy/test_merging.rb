require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestMerging < PistonTestCase
  def setup
    super
    @repos = mock("repository")
    @repos.stubs(:url).returns("http://a.repos.com/svn/trunk")
    @wc = Piston::Svn::WorkingCopy.new("tmp/wc")
    @wcdir = @wc.path
    pathnames << @wcdir

    @from  = mock("fromrevision")
    @to    = mock("torevision")
    @todir = @wcdir + "/.vendor"
  end

  def test_merging_asks_svn_for_dot_piston_yaml_info
    @to.stubs(:revision).returns(9999)
    @wc.stubs(:svn).returns()
    @wc.expects(:svn).with(:info, @wcdir + ".piston.yml").returns(PISTON_YML_INFO)

    @wc.merge_changes(@to)
  end

  def test_merging_asks_svn_to_merge_all_changes_since_last_change_plus_one_on_dot_piston_yml_file
    @to.stubs(:revision).returns(9999)
    @wc.stubs(:svn).with(:info, anything).returns(PISTON_YML_INFO)
    @wc.expects(:svn).with(:merge, "--revision", "9223:#{@to.revision}", @wcdir, @wcdir).returns()
    @wc.merge_changes(@to)
  end

  PISTON_YML_INFO = <<-EOF
Path: tmp/wc/.piston.yml
Name: .piston.yml
URL: http://svn.mycompany.com/project/vendor/.piston.yml
Repository Root: http://svn.mycompany.com/
Repository UUID: bacab574-a924-0410-b505-ece3e248c36c
Revision: 12595
Node Kind: file
Schedule: normal
Last Changed Author: francois
Last Changed Rev: 9223
Last Changed Date: 2008-01-15 21:23:53 -0500 (Mar, 15 jan 2008)
Text Last Updated: 2008-06-20 15:18:10 -0400 (Ven, 20 jui 2008)
Checksum: 209fc8a23dbad779c6c162148c0e92d2
  EOF
end
