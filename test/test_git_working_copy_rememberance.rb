require File.dirname(__FILE__) + "/test_helper"

class TestGitWorkingCopyRememberance < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wcdir.mkdir rescue nil
    @wc = Piston::Git::WorkingCopy.new(@wcdir)
  end

  def teardown
    @wcdir.rmtree
  end

  def test_creates_dot_piston_dot_yml_file
    @wc.remember_values("a" => "b")
    assert((@wcdir + ".piston.yml").exist?)
  end

  def test_writes_values_as_yaml_under_handler_key
    expected = {"a" => "b"}
    @wc.remember_values(expected)
    actual = YAML.load((@wcdir + ".piston.yml").read)
    assert_equal expected, actual["handler"]
  end
end
