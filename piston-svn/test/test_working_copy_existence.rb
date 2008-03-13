require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyExistence < Test::Unit::TestCase
  include Piston::Svn::Client

  def setup
    @reposdir = Pathname.new("tmp/repos")
    svnadmin :create, @reposdir

    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
  end

  def teardown
    @reposdir.rmtree rescue nil
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
    svn :checkout, "file://" + @reposdir.realpath, @wcdir
    assert @wc.exist?
  end
end 
