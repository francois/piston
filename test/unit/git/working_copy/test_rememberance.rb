require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitWorkingCopyRememberance < PistonTestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
  end

  def test_creates_dot_piston_dot_yml_file
    @wc.remember({}, "a" => "b")
    assert((@wcdir + ".piston.yml").exist?)
  end

  def test_writes_values_as_yaml_under_handler_key
    expected = {"a" => "b"}
    @wc.remember({}, expected)
    actual = YAML.load((@wcdir + ".piston.yml").read)
    assert_equal expected, actual["handler"]
  end
end
