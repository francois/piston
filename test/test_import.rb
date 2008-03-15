require File.dirname(__FILE__) + "/test_helper"

class TestImport < Test::Unit::TestCase
  def setup
    @wc = stub_everything("working_copy")
    @cmd = Piston::Commands::Import.new
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
end
