require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyGuessing < Test::Unit::TestCase
  def setup
    PistonCore::WorkingCopy.handlers.clear
    @dir = Pathname.new("tmp/wc")
  end

  def test_guess_when_no_handlers_raises
    assert_raise PistonCore::WorkingCopy::UnhandledWorkingCopy do
      PistonCore::WorkingCopy.guess(@dir)
    end
  end

  def test_guess_asks_each_handler_in_turn
    PistonCore::WorkingCopy.handlers << handler = mock("handler")
    handler.expects(:understands_dir?).with(@dir).returns(false)
    assert_raise PistonCore::WorkingCopy::UnhandledWorkingCopy do
      PistonCore::WorkingCopy.guess(@dir)
    end
  end

  def test_guess_returns_first_handler_that_understands_the_url
    handler = mock("handler")
    handler.expects(:understands_dir?).with(@dir).returns(true)
    handler_instance = mock("handler_instance")
    handler.expects(:new).with(@dir).returns(handler_instance)

    PistonCore::WorkingCopy.handlers << handler
    assert_equal handler_instance, PistonCore::WorkingCopy.guess(@dir)
  end
end
