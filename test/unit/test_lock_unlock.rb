require File.dirname(__FILE__) + "/../test_helper"

class TestLockUnlock < Test::Unit::TestCase
  def setup
    @values = {"lock" => false}
    @wcdir = "tmp/wcdir"
    @wc = mock("WorkingCopy")
  end
  
  def test_lock_working_copy
    run_and_verify(true) do
      @wc.expects(:exist?).returns(true)
      @wc.expects(:pistonized?).returns(true)
      @wc.expects(:recall).returns(@values)
      @wc.expects(:finalize).returns(@values)
      @wc.expects(:remember).with(@values.merge("lock" => true), @values["handler"]).returns(@values)
    end
  end

  def test_unlock_working_copy
    run_and_verify(false) do
      @wc.expects(:exist?).returns(true)
      @wc.expects(:pistonized?).returns(true)
      @wc.expects(:recall).returns(@values)
      @wc.expects(:finalize).returns(@values)
      @wc.expects(:remember).with(@values.merge("lock" => false), @values["handler"]).returns(@values)
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
  def run_and_verify(lock=true)
    yield
    lock_unlock_command.run(@wcdir, lock)
  end

  def lock_unlock_command
    Piston::WorkingCopy.expects(:guess).with(@wcdir).returns(@wc)
    Piston::Commands::LockUnlock.new(:verbose => "verbose",
                                     :quiet => "quiet", :force => "force")
  end
end
