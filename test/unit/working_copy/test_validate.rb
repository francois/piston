require File.expand_path("#{File.dirname(__FILE__)}/../../test_helper")

class TestWorkingCopyValidate < Piston::TestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::WorkingCopy.new(@wcdir)
  end

  def test_exists_when_the_directory_exists
    assert @wc.exist?, "WorkingCopy should have existed, since the directory exists"
  end

  def test_does_not_exist_when_directory_not_present
    @wcdir.rmtree
    deny @wc.exist?, "WorkingCopy should NOT have existed, since the directory does not exist"
  end

  def test_does_not_exist_when_directory_is_a_file
    @wcdir.rmtree
    touch(@wcdir)
    deny @wc.exist?, "WorkingCopy should NOT have existed, since the directory is a file"
  end
  
  def test_is_pistonized_if_exist_and_has_piston_dot_yaml_file
    @wc.stubs(:exist?).returns(true)
    touch(@wcdir + ".piston.yml")
    assert @wc.pistonized?, "WorkingCopy should be Pistonized, since the .piston.yml file exists"
  end

  def test_is_NOT_pistonized_if_no_piston_dot_yaml_file
    @wc.stubs(:exist?).returns(true)
    deny @wc.pistonized?, "WorkingCopy should not be Pistonized, since the .piston.yml does not file exists"
  end

  def test_is_NOT_pistonized_if_exist_returns_false
    @wc.stubs(:exist?).returns(false)
    deny @wc.pistonized?, "WorkingCopy should not be Pistonized, since #exist? returned false"
  end

  def test_is_NOT_pistonized_if_piston_dot_yaml_is_a_directory
    @wc.stubs(:exist?).returns(true)
    (@wcdir + ".piston.yml").mkdir
    deny @wc.pistonized?, "WorkingCopy should not be Pistonized, since .piston.yml is a directory"
  end

  def test_validate_bang_returns_self_when_ok
    @wc.stubs(:pistonized?).returns(true)
    assert_equal @wc, @wc.validate!
  end

  def test_validate_bang_raises_not_working_copy_when_not_pistonized
    @wc.stubs(:pistonized?).returns(false)
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) do
      @wc.validate!
    end
  end

  protected
  def touch(path)
    File.open(path, "wb") {|f| f.write ""}
  end
end
