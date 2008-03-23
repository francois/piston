require File.dirname(__FILE__) + "/../test_helper"

class TestRepositoryGuessing < Test::Unit::TestCase
  def setup
    Piston::Repository.send(:handlers).clear
  end

  def test_guess_when_no_handlers_raises
    assert_raise Piston::Repository::UnhandledUrl do
      Piston::Repository.guess("http://")
    end
  end

  def test_guess_asks_each_handler_in_turn
    Piston::Repository.add_handler(handler = mock("handler"))
    handler.expects(:understands_url?).with("http://a.repos.com/trunk").returns(false)
    assert_raise Piston::Repository::UnhandledUrl do
      Piston::Repository.guess("http://a.repos.com/trunk")
    end
  end

  def test_guess_returns_first_handler_that_understands_the_url
    url = "svn://a.repos.com/projects/libcalc/trunk"

    handler = mock("handler")
    handler.expects(:understands_url?).with(url).returns(true)
    handler_instance = mock("handler_instance")
    handler.expects(:new).with(url).returns(handler_instance)

    Piston::Repository.add_handler handler
    assert_equal handler_instance, Piston::Repository.guess(url)
  end
end
