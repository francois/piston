require File.expand_path("#{File.dirname(__FILE__)}/../../test_helper")

class TestWorkingCopyInfo < Piston::TestCase
  def setup
    super
    @path = mkpath("tmp/wc")
    @wc = Piston::WorkingCopy.new(@path)
  end
  
  def test_info_recalls_values
    @wc.expects(:recall).returns(values = mock("recalled values"))
    assert_equal values, @wc.info
  end
end
