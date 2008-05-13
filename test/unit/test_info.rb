require File.dirname(__FILE__) + "/../test_helper"

class TestInfo < Test::Unit::TestCase
  def setup
    @values = {"lock" => false}
    @wcdir = "tmp/wcdir"
    @wc = mock("WorkingCopy")
  end
  
  def test_info
    run_and_verify do
      @wc.expects(:exist?).returns(true)
      @wc.expects(:pistonized?).returns(true)
      @wc.expects(:info)
    end
  end

  def test_run_when_directory_not_exist
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) do
      run_and_verify do
        @wc.expects(:exist?).returns(false)
      end
    end
  end
  
  def test_run_when_directory_exist_but_yml_not_exit
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) do
      run_and_verify do
        @wc.expects(:exist?).returns(true)
        @wc.expects(:pistonized?).returns(false)
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
