require File.dirname(__FILE__) + "/../test_helper"

class TestLockUnlock < Test::Unit::TestCase
  def setup
    @values = {:lock => "false", "handler" => { :repository => "repository" }}
    @wc = mock("WorkingCopy")
  end
  
  def test_run
    run_and_verify do
      @wc.expects(:exist?).returns(true)
      @wc.expects(:pistonized?).returns(true)
      @wc.expects(:recall).returns(@values)
      @wc.expects(:finalize).returns(@values)
      @wc.expects(:remember).with(@values, @values["handler"]).returns(@values)
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
    piston_lock.run(true)
  end

  def piston_lock
    Piston::WorkingCopy.expects(:guess).with("directory").returns(@wc)                                   
    Piston::Commands::LockUnlock.new(:wcdir => "directory", :verbose => "verbose",
                                     :quiet => "quiet", :force => "force")
  end
end
