require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestImport < PistonTestCase
  def setup
    super
    @wc = stub_everything("working_copy")
    @cmd = Piston::Commands::Import.new
  end

  def test_temp_dir_name_hides_tmpdir_as_a_dotfile_and_suffixes_with_tmp
    @wc.stubs(:path).returns(Pathname.new("tmp/a/dir"))
    assert_equal Pathname.new("tmp/a/.dir.tmp"), @cmd.temp_dir_name(@wc)
  end
end
