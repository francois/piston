require File.dirname(__FILE__) + "/../test_helper"

class TestSvnRepositoryBasename < Test::Unit::TestCase
  def test_basename_is_urls_path_last_component
    assert_equal "piston", basename("http://svn.rubyforge.org/var/svn/piston")
  end

  def test_basename_is_urls_path_last_component_minus_trunk
    assert_equal "attachment_fu", basename("svn+ssh://some.host.com/svn/attachment_fu/trunk")
  end

  def test_basename_is_urls_path_last_component_before_branches
    assert_equal "rails", basename("svn://some.host.com/svn/rails/branches/stable")
  end

  def test_basename_is_urls_path_last_component_before_tags
    assert_equal "plugin", basename("https://some.host.com/svn/plugin/tags/stable")
  end

  private
  def basename(url)
    Piston::Svn::Repository.new(url).basename
  end
end
