require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestInfo < Piston::TestCase
  def setup
    super
    @values = {"lock" => false}
    @wcdir = "tmp/wcdir"
    @wc = mock("WorkingCopy")
    @wc.stubs(:validate!)
  end
  
  def test_info
    run_and_verify do
      @wc.expects(:info)
    end
  end

  def test_validates_working_copy_before_working
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) do
      run_and_verify do
        @wc.expects(:validate!).raises(Piston::WorkingCopy::NotWorkingCopy)
      end
    end
  end

  private
  def run_and_verify
    yield
    info_command.run(@wcdir)
  end

  def info_command
    Piston::WorkingCopy.expects(:guess).with(@wcdir).returns(@wc)
    Piston::Commands::Info.new(:verbose => "verbose",
                                     :quiet => "quiet", :force => "force")
  end
end
