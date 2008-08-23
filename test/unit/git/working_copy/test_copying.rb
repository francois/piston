require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitWorkingCopyCopying < PistonTestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
    @wc.stubs(:git)
  end

  def test_copies_file
    files = ["file.rb"]
    files.expects(:copy_to).with("file.rb", @wcdir + files.first)
    @wc.copy_from(files)
  end

  def test_ensures_directories_are_created
    files = ["file/a.rb"]
    @wcdir.expects(:+).with(files.first).returns(target = mock("target"))
    target.expects(:dirname).returns(target)
    target.expects(:mkdir)
    files.expects(:copy_to).with("file/a.rb", target)
    @wc.copy_from(files)
  end
end
