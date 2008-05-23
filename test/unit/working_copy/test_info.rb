require File.dirname(__FILE__) + "/../../test_helper"

class TestWorkingCopyInfo < Test::Unit::TestCase
  def setup
    @path = Pathname.new("tmp/wc")
    @wc = Piston::WorkingCopy.new(@path)
  end
  
  def test_info_recalls_values
    @wc.expects(:recall).returns(values = mock("recalled values"))
    assert_equal values, @wc.info
  end
end
