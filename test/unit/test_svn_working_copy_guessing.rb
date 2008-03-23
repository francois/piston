require File.dirname(__FILE__) + "/../test_helper"

class TestSvnWorkingCopyGuessing < Test::Unit::TestCase
  def setup
    @dir = Pathname.new("tmp/wc")
  end

  def test_does_svn_info_on_directory
    Piston::Svn::WorkingCopy.expects(:svn).with(:info, @dir).returns("Path: xxx\n")
    assert Piston::Svn::WorkingCopy.understands_dir?(@dir)
  end

  def test_denies_when_svn_not_available
    Piston::Svn::WorkingCopy.expects(:svn).with(:info, @dir).raises(Piston::Svn::Client::BadCommand)
    deny Piston::Svn::WorkingCopy.understands_dir?(@dir)
  end
end
