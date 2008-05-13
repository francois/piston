require File.dirname(__FILE__) + "/../test_helper"

class TestLockUnlock < Test::Unit::TestCase
  def setup
    @values = {"lock" => false}
    @wcdir = "tmp/wcdir"
    @wc = mock("WorkingCopy")
    @wc.stubs(:validate!)
  end

  def test_lock_working_copy
    run_and_verify(true) do
      @wc.expects(:recall).returns(@values)
      @wc.expects(:finalize).returns(@values)
      @wc.expects(:remember).with(@values.merge("lock" => true), @values["handler"]).returns(@values)
    end
  end

  def test_unlock_working_copy
    run_and_verify(false) do
      @wc.expects(:recall).returns(@values)
      @wc.expects(:finalize).returns(@values)
      @wc.expects(:remember).with(@values.merge("lock" => false), @values["handler"]).returns(@values)
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
