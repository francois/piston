require File.dirname(__FILE__) + "/test_helper"

class TestSvnWorkingCopyRememberance < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wcdir.mkpath
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_creates_dot_piston_dot_yml_file
    @wc.remember("a" => "b")
    assert((@wcdir + ".piston.yml").exist?)
  end

  def test_writes_values_as_yaml_under_handler_key
    expected = {"a" => "b"}
    @wc.remember(expected)
    actual = YAML.load((@wcdir + ".piston.yml").read)
    assert_equal expected, actual["handler"]
  end
end
