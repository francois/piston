require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyExistence < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = PistonSvn::WorkingCopy.new(@wcdir)
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_exist_false_when_dir_not_present
    deny @wc.exist?
  end

  def test_exist_false_when_dir_present_but_not_an_svn_wc
    @wcdir.mkdir
    deny @wc.exist?
  end

  def test_exist_true_when_svn_working_copy_at_path
    @wc.expects(:svn).with(:info, @wcdir).returns("a:b")
    assert @wc.exist?
  end
end 
