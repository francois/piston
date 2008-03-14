require File.dirname(__FILE__) + "/test_helper"

class TestRepositoryGuessing < Test::Unit::TestCase
  def setup
    PistonCore::Repository.handlers.clear
  end

  def test_guess_when_no_handlers_raises
    assert_raise PistonCore::Repository::UnhandledUrl do
      PistonCore::Repository.guess("http://")
    end
  end

  def test_guess_asks_each_handler_in_turn
    PistonCore::Repository.handlers << handler = mock("handler")
    handler.expects(:understands_url?).with("http://a.repos.com/trunk").returns(false)
    assert_raise PistonCore::Repository::UnhandledUrl do
      PistonCore::Repository.guess("http://a.repos.com/trunk")
    end
  end

  def test_guess_returns_first_handler_that_understands_the_url
    url = "svn://a.repos.com/projects/libcalc/trunk"

    handler = mock("handler")
    handler.expects(:understands_url?).with(url).returns(true)
    handler_instance = mock("handler_instance")
    handler.expects(:new).with(url).returns(handler_instance)

    PistonCore::Repository.handlers << handler
    assert_equal handler_instance, PistonCore::Repository.guess(url)
  end
end
