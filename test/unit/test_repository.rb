require File.dirname(__FILE__) + "/../test_helper"

class TestRepository < Test::Unit::TestCase
  
  def setup
    Piston::Repository.class_variable_set(:@@handlers, [Piston::Git::Repository, Piston::Svn::Repository])
    @repository = Piston::Repository.new("url")
  end
  
  def test_guess_asks_each_handler_in_turn
    Piston::Repository.send(:handlers).clear
    Piston::Repository.add_handler(handler = mock("handler"))
    handler.expects(:understands_url?).with("http://a.repos.com/trunk").returns(false)
    assert_raise Piston::Repository::UnhandledUrl do
      Piston::Repository.guess("http://a.repos.com/trunk")
    end
  end

  def test_guess_returns_first_handler_that_understands_the_url
    Piston::Repository.send(:handlers).clear
    url = "svn://a.repos.com/projects/libcalc/trunk"

    handler = mock("handler")
    handler.expects(:understands_url?).with(url).returns(true)
    handler_instance = mock("handler_instance")
    handler.expects(:new).with(url).returns(handler_instance)

    Piston::Repository.add_handler handler
    assert_equal handler_instance, Piston::Repository.guess(url)
  end
  
  
  def test_if_guess_return_GIT_repository_when_url_is_git_repository
    assert_equal Piston::Git::Repository.new("git://github.com/francois/piston.git"), Piston::Repository.guess("git://github.com/francois/piston.git")
  end

  def test_if_guess_return_SVN_repository_when_url_is_svn_repository
    assert_equal Piston::Svn::Repository.new("svn://svn.com/francois/piston.git"), Piston::Repository.guess("svn://svn.com/francois/piston.git")
  end
  
  def test_guess_when_unhandled_url
    assert_raise(Piston::Repository::UnhandledUrl) {    Piston::Repository.guess("invalid")    }
  end
  
  def test_handlers
    assert_equal [Piston::Git::Repository, Piston::Svn::Repository], Piston::Repository.handlers
  end
  
  def test_add_handler
    before_add = Piston::Repository.class_variable_get(:@@handlers)
    after_add = before_add << Piston::Git::Repository
    Piston::Repository.add_handler(Piston::Git::Repository)
    assert_equal after_add, Piston::Repository.class_variable_get(:@@handlers)
  end
  
  def test_initialize
    assert_equal "url", @repository.instance_variable_get(:@url)
  end
  
  def test_url
    assert_equal "url", @repository.url
  end
  
  def test_at
    revision = @repository.at("2")
    assert_equal @repository, revision.repository
    assert_equal "2", revision.revision
  end
  
  def test_to_s
    assert_equal "Piston::Repository(url)", @repository.to_s
  end
  
end
