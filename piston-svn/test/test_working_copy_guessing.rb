require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyGuessing < Test::Unit::TestCase
  def setup
    @dir = Pathname.new("tmp/wc")
  end

  def test_does_svn_info_on_directory
    PistonSvn::WorkingCopy.expects(:svn).with(:info, @dir).returns("Path: xxx\n")
    assert PistonSvn::WorkingCopy.understands_dir?(@dir)
  end

  def test_denies_when_svn_not_available
    PistonSvn::WorkingCopy.expects(:svn).with(:info, @dir).raises(PistonSvn::Client::BadCommand)
    deny PistonSvn::WorkingCopy.understands_dir?(@dir)
  end
end
