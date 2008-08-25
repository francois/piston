require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestSvnRevisionValidation < PistonTestCase
  def setup
    super
    @repository = mock("repository")
    @repository.stubs(:url).returns("svn://svn.my-repos.com/projects/libcalc/trunk")
  end
  
  def test_revision_is_invalid_unless_same_uuid
    rev = new_revision("HEAD", Piston::Svn::UUID => "1234")
    rev.expects(:svn).with(:info, "--revision", "HEAD", @repository.url).returns(INFO)
    assert_raise Piston::Svn::Revision::UuidChanged do
      rev.validate!
    end
  end

  def test_revision_is_invalid_if_repository_location_does_not_exist_anymore
    rev = new_revision("HEAD", Piston::Svn::UUID => "038cbeb6-2227-0410-91ec-8f9533625906")
    rev.expects(:svn).with(:info, "--revision", "HEAD", @repository.url).returns("#{@repository.url}:  (Not a valid URL)")
    assert_raise Piston::Svn::Revision::RepositoryMoved do
      rev.validate!
    end
  end

  def test_revision_is_valid_if_repository_is_present_and_same_uuid
    rev = new_revision("HEAD", Piston::Svn::UUID => "038cbeb6-2227-0410-91ec-8f9533625906")
    rev.expects(:svn).with(:info, "--revision", "HEAD", @repository.url).returns(INFO)
    assert_nothing_raised do
      rev.validate!
    end
  end

  protected
  def new_revision(rev, recalled_values={})
    Piston::Svn::Revision.new(@repository, rev, recalled_values)
  end
  
  INFO = <<EOF
Path: project
URL: svn://svn.my-repos.com/projects/libcalc/trunk
Repository Root: svn://svn.my-repos.com/projects
Repository UUID: 038cbeb6-2227-0410-91ec-8f9533625906
Revision: 1234
Node Kind: directory
Last Changed Author: francois
Last Changed Rev: 1232
Last Changed Date: 2008-04-06 21:57:10 -0400 (Sun, 06 Apr 2008)
EOF
end