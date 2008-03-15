require File.dirname(__FILE__) + "/test_helper"

class TestSvnWorkingCopyFinalization < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = PistonSvn::WorkingCopy.new(@wcdir)
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_finalize_adds_all_top_level_entries_to_working_copy
    @wcdir.mkdir
    File.open(@wcdir + "a.rb", "wb") {|f| f.write "Hello World!"}
    File.open(@wcdir + "b.rb", "wb") {|f| f.write "Hello World!"}
    @wc.expects(:svn).with(:add, (@wcdir + "a.rb").to_s)
    @wc.expects(:svn).with(:add, (@wcdir + "b.rb").to_s)
    @wc.finalize
  end
end
