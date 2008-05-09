require File.dirname(__FILE__) + "/../test_helper"

class TestLock < Test::Unit::TestCase
  
  def setup
    @values_mock = {:lock => "false", "handler" => { :repository => "repository" }}
    @wc_mock = mock("WorkingCopy")
  end
  
  def test_run
    run_and_verify do
      @wc_mock.expects(:exist?).returns(true)
      @wc_mock.expects(:pistonized?).returns(true)
      @wc_mock.expects(:recall).returns(@values_mock)
      @wc_mock.expects(:finalize).returns(@values_mock)
      @wc_mock.expects(:remember).with(@values_mock, @values_mock["handler"]).returns(@values_mock)
    end
  end
  
  def test_run_when_directory_not_exist
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) do
      run_and_verify do
        @wc_mock.expects(:exist?).returns(false)
      end
    end
  end
  
  def test_run_when_directory_exist_but_yml_not_exit
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) do
      run_and_verify do
        @wc_mock.expects(:exist?).returns(true)
        @wc_mock.expects(:pistonized?).returns(false)
      end
    end
  end
  
  private
  
  def run_and_verify
    yield
    get_piston_lock.run(true)
  end
  
  def get_piston_lock
    Piston::WorkingCopy.expects(:guess).with("directory").returns(@wc_mock)                                   
    Piston::Commands::Lock.new(  :wcdir => "directory",
                                       :verbose => "verbose",
                                       :quiet => "quiet",
                                       :force => "force")
  end
  
end
