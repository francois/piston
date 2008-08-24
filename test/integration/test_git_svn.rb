require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestGitSvn < PistonTestCase
  attr_reader :root_path, :parent_path, :repos_path, :wc_path

  def setup
    super
    @root_path = mkpath("/tmp/import_git_svn")

    @repos_path = @root_path + "repos"

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

    svnadmin :create, repos_path
    svn :checkout, "file://#{repos_path}", wc_path
    svn :mkdir, wc_path + "trunk", wc_path + "tags", wc_path + "branches", wc_path + "trunk/vendor"
    svn :commit, wc_path, "--message", "'first commit'"
  end

  def test_import
    piston(:import, parent_path, wc_path + "trunk/vendor/parent")

    assert_equal ADD_STATUS.split("\n").sort, svn(:status, wc_path + "trunk/vendor").gsub((wc_path + "trunk/").to_s, "").split("\n").sort

    info = YAML.load(File.read(wc_path + "trunk/vendor/parent/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal parent_path.to_s, info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    response = `git-ls-remote #{parent_path}`
    head_commit = response.grep(/HEAD/).first.chomp.split(/\s+/).first
    assert_equal head_commit, info["handler"][Piston::Git::COMMIT]
  end

  def test_import_from_branch
    Dir.chdir(parent_path) do
      git(:branch, "rewrite")
      git(:checkout, "rewrite")
      touch("file_in_branch")
      git(:add, ".")
      git(:commit, "-m", "'commit after branch'")
    end
    piston(:import, "--revision", "origin/rewrite", parent_path, wc_path + "trunk/vendor/parent")

    assert File.exists?(wc_path + "trunk/vendor/parent/file_in_branch"),
        "Could not find file_in_branch in parent imported directory."

    info = YAML.load(File.read(wc_path + "trunk/vendor/parent/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal parent_path.to_s, info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    response = `git-ls-remote #{parent_path}`
    head_commit = response.grep(/refs\/heads\/rewrite/).first.chomp.split(/\s+/).first
    assert_equal head_commit, info["handler"][Piston::Git::COMMIT]
    assert_equal "origin/rewrite", info["handler"][Piston::Git::BRANCH]
  end

  def test_import_from_tag
    Dir.chdir(parent_path) do
      git(:tag, "the_tag_name")
      touch("file_past_tag")
      git(:add, ".")
      git(:commit, "-m", "'commit after tag'")
    end
    piston(:import, "--revision", "the_tag_name", parent_path, wc_path + "trunk/vendor/parent")

    info = YAML.load(File.read(wc_path + "trunk/vendor/parent/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal parent_path.to_s, info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    response = `git-ls-remote #{parent_path} the_tag_name`
    tagged_commit = response.chomp.split(/\s+/).first
    assert_equal tagged_commit, info["handler"][Piston::Git::COMMIT]
    assert_equal "the_tag_name", info["handler"][Piston::Git::BRANCH]
  end

  ADD_STATUS = %Q(A      vendor/parent
A      vendor/parent/.piston.yml
A      vendor/parent/README
A      vendor/parent/file_in_first_commit
)
end
