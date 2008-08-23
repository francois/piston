require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")
require "find"

class TestGitCommitEach < Test::Unit::TestCase
  def setup
    @repos = mock("repository")
    @repos.stubs(:url).returns("git://github.com/francois/arepos.git")

    @tmpdir = Pathname.new("tmp/.arepos.tmp.git")
    @tmpdir.rmtree rescue nil
    @tmpdir.mkdir
    @commit = Piston::Git::Commit.new(@repos, "ab"*20)
    @commit.stubs(:git).returns("commit " + "ab" * 20)
    @commit.checkout_to(@tmpdir)
  end

  def teardown
    @tmpdir.rmtree
  end

  def test_prunes_search_tree_on_dot_git_directory
    @tmpdir.expects(:find).yields(@tmpdir + ".git")
    assert_throws :prune do
      @commit.each do |relpath| 
        # Can't assert anything
      end
    end
  end

  def test_yields_paths_relative_to_working_copy
    @tmpdir.expects(:find).yields(@tmpdir + "a.rb")
    @commit.each do |relpath|
      assert_equal Pathname.new("a.rb"), relpath
    end
  end
end
