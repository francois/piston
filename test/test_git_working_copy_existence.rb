require File.dirname(__FILE__) + "/test_helper"

class TestGitWorkingCopyExistence < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_exist_false_when_no_dir
    deny @wc.exist?
  end

  def test_exist_true_when_dir_present
    @wcdir.mkdir
    assert @wc.exist?
  end
end
