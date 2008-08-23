require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestRepository < PistonTestCase
  def setup
    super
    Piston::Repository.send(:handlers).clear
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

  def test_guess_raises_unhandled_url_exception_when_no_repository_handler_found
    assert_raise(Piston::Repository::UnhandledUrl) do
      Piston::Repository.guess("invalid")
    end
  end

  def test_add_handler
    Piston::Repository.add_handler(handler = mock("handler"))
    assert_equal [handler], Piston::Repository.send(:handlers)
  end

  def test_initialize_stores_url_parameter_in_url_accessor
    @repository = Piston::Repository.new("url")
    assert_equal "url", @repository.url
  end

  def test_at_is_a_subclass_responsibility
    @repository = Piston::Repository.new("url")
    assert_raise(SubclassResponsibilityError) do
      @repository.at(:any)
    end
  end
end
