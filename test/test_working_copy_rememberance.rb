require File.dirname(__FILE__) + "/test_helper"

class TestWorkingCopyRememberance < Test::Unit::TestCase
  def setup
    @wcpath = Pathname.new("tmp/wc")
    @wcpath.rmtree rescue nil
    @wcpath.mkpath
    @wc = Piston::WorkingCopy.new(@wcpath)
  end

  def teardown
    @wcpath.rmtree rescue nil
  end

  def test_remember_generates_piston_yml_file_in_wc
    @wc.remember("a" => "b")
    assert((@wcpath + ".piston.yml").exist?, "tmp/wc/.piston.yml file doesn't exist")
  end

  def test_remember_calls_after_remember_with_path_to_piston_yml_file
    @wc.expects(:after_remember).with(@wcpath + ".piston.yml")
    @wc.remember("a" => "b")
  end
end
