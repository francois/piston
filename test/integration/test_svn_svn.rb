require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestSvnSvn < Piston::TestCase
  attr_reader :root_path, :repos_path, :wc_path, :parent_path

  def setup
    super
    @root_path = mkpath("/tmp/import_svn_svn")
    @repos_path = @root_path + "repos"
    @parent_path = @root_path + "parent"
    @wc_path = @root_path + "wc"

    svnadmin :create, repos_path
    svn :checkout, "file://#{repos_path}", wc_path
    Dir.chdir(wc_path) do
      svn :mkdir, "--parents", "parent", "wc/tags", "wc/branches", "wc/trunk/vendor"
      File.open("parent/README", "wb") {|f| f.write "Readme - first commit\n"}
      File.open("parent/file_in_first_commit", "wb") {|f| f.write "file_in_first_commit"}
      svn :add, "parent/*"
    end
    svn :commit, wc_path, "--message", "'first commit'"

    FileUtils.rm_rf wc_path
    svn :checkout, "file://#{repos_path}/wc", wc_path
    svn :checkout, "file://#{repos_path}/parent", parent_path
  end

  def test_import
    Dir.chdir(wc_path + "trunk/vendor") do # make a test guessing the path where import
      piston :import, "http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement/"
    end

    assert_equal "A      vendor/ssl_requirement
A      vendor/ssl_requirement/test
A      vendor/ssl_requirement/test/ssl_requirement_test.rb
A      vendor/ssl_requirement/lib
A      vendor/ssl_requirement/lib/ssl_requirement.rb
A      vendor/ssl_requirement/.piston.yml
A      vendor/ssl_requirement/README
".split("\n").sort, svn(:status, wc_path + "trunk/vendor/").gsub((wc_path + "trunk/").to_s, "").split("\n").sort

    info = YAML.load_file(wc_path + "trunk/vendor/ssl_requirement/.piston.yml")
    assert_equal 1, info["format"]
    assert_equal "http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement/", info["repository_url"]
    assert_equal "Piston::Svn::Repository", info["repository_class"]
    assert_equal "5ecf4fe2-1ee6-0310-87b1-e25e094e27de", info["handler"][Piston::Svn::UUID]
  end

  def test_update
    Dir.chdir(wc_path) do
      piston(:import, "file://#{repos_path}/parent", "trunk/vendor/parent")
    end
    # change mode to "ab" to get a conflict when it's implemented
    File.open(wc_path + "trunk/vendor/parent/README", "wb") do |f|
      f.write "Readme - modified after imported\nReadme - first commit\n"
    end

    svn(:commit, wc_path, "-m", "'next commit'")

    Dir.chdir(parent_path) do
      File.open("README", "ab") {|f| f.write "Readme - second commit\n"}
      svn(:rm, "file_in_first_commit")
      File.open("file_in_second_commit", "wb") {|f| f.write "file_in_second_commit"}
      svn(:add, "file_in_second_commit")
      svn(:commit, "-m", "'second commit'")
    end

    Dir.chdir(wc_path) do
      piston(:update, "trunk/vendor/parent")
    end

    Dir.chdir(wc_path) do
      assert_equal CHANGE_STATUS.split("\n").sort, svn(:status).gsub("trunk/", "").split("\n").sort
    end
    assert_equal README, File.readlines(wc_path + "trunk/vendor/parent/README").join
  end

  CHANGE_STATUS = %Q(M      vendor/parent/.piston.yml
M      vendor/parent/README
D      vendor/parent/file_in_first_commit
A      vendor/parent/file_in_second_commit
)
  README = %Q(Readme - modified after imported
Readme - first commit
Readme - second commit
)
end
