require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestSvnWorkingCopyFinalization < Piston::TestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
  end

  def test_finalize_adds_all_top_level_entries_to_working_copy
    File.open(@wcdir + "a.rb", "wb") {|f| f.write "Hello World!"}
    File.open(@wcdir + "b.rb", "wb") {|f| f.write "Hello World!"}
    @wc.expects(:svn).with(:add, (@wcdir + "a.rb").to_s)
    @wc.expects(:svn).with(:add, (@wcdir + "b.rb").to_s)
    @wc.finalize
  end
end
