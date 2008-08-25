require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestGitGit < PistonTestCase
  attr_reader :root_path, :repos_path, :parent_path, :wc_path

  def setup
    super
    @root_path = mkpath("/tmp/import_git_git")

    @parent_path = root_path + "parent"
    mkpath(parent_path)

    @wc_path = root_path + "wc"
    mkpath(wc_path)

    Dir.chdir(parent_path) do
      git(:init)
      File.open(parent_path + "README", "wb") {|f| f.write "Readme - first commit"}
      File.open(parent_path + "file_in_first_commit", "wb") {|f| f.write "file_in_first_commit"}
      git(:add, ".")
      git(:commit, "-m", "'first commit'")
    end

    Dir.chdir(wc_path) do
      git(:init)
      File.open(wc_path + "README", "wb") {|f| f.write "Hello World!"}
      (wc_path + "vendor").mkdir
      File.open(wc_path + "vendor/.gitignore", "wb") {|f| f.write "*.swp"}
      git(:add, ".")
      git(:commit, "-m", "'first commit'")
    end
  end

  def test_import
    piston(:import, parent_path, wc_path + "vendor/parent")

    Dir.chdir(wc_path) do
      assert_equal IMPORT_STATUS.split("\n").sort, git(:status).split("\n").sort
    end

    info = YAML.load(File.read(wc_path + "vendor/parent/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal parent_path.to_s, info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    response = `git-ls-remote #{parent_path}`
    head_commit = response.grep(/HEAD/).first.chomp.split(/\s+/).first
    assert_equal head_commit, info["handler"][Piston::Git::COMMIT]
  end

  IMPORT_STATUS = %Q(# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#\tnew file:   vendor/parent/.piston.yml
#\tnew file:   vendor/parent/README
#\tnew file:   vendor/parent/file_in_first_commit
#
)

  def test_update
    piston(:import, parent_path, wc_path + "vendor/parent")

    Dir.chdir(wc_path) do
      git(:add, ".")
      git(:commit, "-m", "'next commit'")
    end

    Dir.chdir(parent_path) do
      File.open(parent_path + "README", "wb") {|f| f.write "Readme - second commit"}
      FileUtils.rm(parent_path + "file_in_first_commit")
      File.open(parent_path + "file_in_second_commit", "wb") {|f| f.write "file_in_second_commit"}
      git(:add, ".")
      git(:commit, "-m", "'second commit'")
    end

    piston(:update, wc_path + "vendor/parent")

    Dir.chdir(wc_path) do
      assert_equal CHANGE_STATUS.split("\n"), git(:status).split("\n")
    end
  end

  CHANGE_STATUS = %Q(# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#\tmodified:   vendor/parent/.piston.yml
#\tmodified:   vendor/parent/README
#\tnew file:   vendor/parent/file_in_second_commit
#
)
end
