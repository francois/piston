require File.dirname(__FILE__) + "/test_helper"
require "piston_core/commands/import"
require "pathname"

class TestImport < Test::Unit::TestCase
  def setup
    @wc = stub_everything("working_copy")
    @cmd = PistonCore::Commands::Import.new
    @cmd.stubs(:debug)
    @cmd.stubs(:info)
    @cmd.stubs(:warn)
    @cmd.stubs(:error)
    @cmd.stubs(:fatal)
  end

  def test_temp_dir_name_hides_tmpdir_as_a_dotfile_and_suffixes_with_tmp
    @wc.stubs(:path).returns(Pathname.new("tmp/a/dir"))
    assert_equal Pathname.new("tmp/a/.dir.tmp"), @cmd.temp_dir_name(@wc)
  end

  def test_create_tmpdir_creates_specified_dir
    tmpdir = Pathname.new("tmp/newdir")
    begin
      tmpdir.rmtree rescue nil
      @cmd.create_tmpdir(tmpdir)
      assert tmpdir.exist?, "#{tmpdir} doesn't exist"
      assert tmpdir.directory?, "#{tmpdir} isn't a directory"
    ensure
      tmpdir.rmtree
    end
  end

  def test_create_tmpdir_removes_existing_dir_and_creates_again
    tmpdir = Pathname.new("tmp/newdir")
    begin
      tmpdir.rmtree rescue nil
      tmpdir.mkdir
      file = tmpdir + "a.rb"
      File.open(file, "wb") {|f| f.write "bla" }
      @cmd.create_tmpdir(tmpdir)
      assert tmpdir.exist?, "#{tmpdir} doesn't exist"
      assert tmpdir.directory?, "#{tmpdir} isn't a directory"
      deny file.exist?, "#{file} still exists"
    ensure
      tmpdir.rmtree
    end
  end
end
