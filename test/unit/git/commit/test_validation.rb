require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Git::TestGitCommitValidation < PistonTestCase
  def setup
    super
    @repository = mock("repository")
    @repository.stubs(:url).returns("git://my-git-repos/my-project.git")
  end

  def test_is_invalid_if_cannot_ls_remote_repository
    commit = new_commit("HEAD")
    commit.expects(:git).with("ls-remote", @repository.url).raises(Piston::Git::Client::CommandError)
    assert_raise Piston::Git::Commit::Gone do
      commit.validate!
    end
  end

  def test_is_valid_when_ls_remote_succeeds
    commit = new_commit("HEAD")
    commit.expects(:git).with("ls-remote", @repository.url).returns(INFO)
    assert_nothing_raised do
      commit.validate!
    end
  end

  protected
  def new_commit(commit, recalled_values={})
    Piston::Git::Commit.new(@repository, commit, recalled_values)
  end
  
  INFO = <<EOF
a7c46c702243f145a4089b0cb33d189870f1ae53	HEAD
EOF
end