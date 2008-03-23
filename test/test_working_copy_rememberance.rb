require File.dirname(__FILE__) + "/test_helper"

class TestWorkingCopyRememberance < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wcdir.rmtree rescue nil
    @wcdir.mkpath
    @wc = Piston::WorkingCopy.new(@wcdir)
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_remember_generates_piston_yml_file_in_wc
    @wc.remember("a" => "b")
    assert((@wcdir + ".piston.yml").exist?, "tmp/wc/.piston.yml file doesn't exist")
  end

  def test_writes_values_as_yaml_under_handler_key
    expected = {"a" => "b"}
    @wc.remember(expected)
    actual = YAML.load((@wcdir + ".piston.yml").read)
    assert_equal expected, actual["handler"]
  end

  def test_remember_calls_after_remember_with_path_to_piston_yml_file
    @wc.expects(:after_remember).with(@wcdir + ".piston.yml")
    @wc.remember("a" => "b")
  end
end
