require File.dirname(__FILE__) + "/../../../test_helper"

class TestSvnRepositoryAt < Test::Unit::TestCase
  def setup
    @repos = Piston::Svn::Repository.new("http://bla.com/svn/repos/trunk")
  end

  def test_instantiate_revision_at_head
    Piston::Svn::Revision.expects(:new).with(@repos, "HEAD").returns(:newrev)
    assert_equal :newrev, @repos.at(:head)
  end

  def test_instantiate_revision_using_recalled_values
    Piston::Svn::Revision.expects(:new).with(@repos, 9123).returns(:newrev)
    assert_equal :newrev, @repos.at(Piston::Svn::REMOTE_REV => 9123,
                                    Piston::Svn::UUID => "5ecf4fe2-1ee6-0310-87b1-e25e094e27de")
  end
end
