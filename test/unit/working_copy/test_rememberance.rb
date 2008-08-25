require File.expand_path("#{File.dirname(__FILE__)}/../../test_helper")

class TestWorkingCopyRememberance < Piston::TestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::WorkingCopy.new(@wcdir)
  end

  def test_remember_generates_piston_yml_file_in_wc
    @wc.remember({}, "a" => "b")
    assert((@wcdir + ".piston.yml").exist?, "tmp/wc/.piston.yml file doesn't exist")
  end

  def test_writes_values_as_yaml_under_handler_key
    expected = {"a" => "b"}
    @wc.remember({}, expected)
    actual = YAML.load_file(@wcdir + ".piston.yml")
    assert_equal expected, actual["handler"]
  end

  def test_remember_calls_after_remember_with_path_to_piston_yml_file
    @wc.expects(:after_remember).with(@wcdir + ".piston.yml")
    @wc.remember({}, "a" => "b")
  end

  def test_remember_with_two_args_remembers_handler_values_separately
    values = {"lock" => true}
    handler_values = {"a" => "b"}

    @wc.remember(values, handler_values)

    actual = YAML.load_file(@wcdir + ".piston.yml")
    assert_equal values.merge("format" => 1, "handler" => handler_values), actual
  end

  def test_recall_returns_hash_of_values
    values = {"a" => "b", "handler" => {"b" => "c"}}
    YAML.expects(:load_file).with(@wcdir + ".piston.yml").returns(values)
    assert_equal values, @wc.recall
  end
end
