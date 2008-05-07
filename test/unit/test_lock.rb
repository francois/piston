require File.dirname(__FILE__) + "/../test_helper"

class TestImport < Test::Unit::TestCase
  
  def test_run
    values_mock = {:lock => "false", "handler" => { :repository => "repository" }}
    
    wc_mock = mock("WorkingCopy")
    wc_mock.expects(:exist?).returns(true)
    wc_mock.expects(:pistonized?).returns(true)
    wc_mock.expects(:recall).returns(values_mock)
    wc_mock.expects(:finalize).returns(values_mock)
    wc_mock.expects(:remember).with(values_mock, values_mock["handler"]).returns(values_mock)
    Piston::WorkingCopy.expects(:guess).with("directory").returns(wc_mock)                                   
    get_piston_lock.run(true)
  end
  
  def test_run_when_directory_not_exist
    values_mock = {:lock => "false", "handler" => { :repository => "repository" }}
    wc_mock = mock("WorkingCopy")
    wc_mock.expects(:exist?).returns(false)
    Piston::WorkingCopy.expects(:guess).with("directory").returns(wc_mock)                                   
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) { get_piston_lock.run(true) }
  end
  
  def test_run_when_directory_exist_but_yml_not_exit
    values_mock = {:lock => "false", "handler" => { :repository => "repository" }}
    wc_mock = mock("WorkingCopy")
    wc_mock.expects(:exist?).returns(true)
    wc_mock.expects(:pistonized?).returns(false)
    Piston::WorkingCopy.expects(:guess).with("directory").returns(wc_mock)                                   
    assert_raise(Piston::WorkingCopy::NotWorkingCopy) { get_piston_lock.run(true) }
  end
  
  def get_piston_lock
    
    Piston::Commands::Lock.new(  :wcdir => "directory",
                                       :verbose => "verbose",
                                       :quiet => "quiet",
                                       :force => "force")
  end
  
end
