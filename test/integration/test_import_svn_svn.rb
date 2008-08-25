require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestImportSvnSvn < Piston::TestCase
  attr_reader :root_path, :repos_path, :wc_path

  def setup
    super
    @root_path = mkpath("/tmp/import_svn_svn")
    @repos_path = @root_path + "repos"
    @wc_path = @root_path + "wc"

    svnadmin :create, repos_path
    svn :checkout, "file://#{repos_path}", wc_path
    svn :mkdir, wc_path + "trunk", wc_path + "tags", wc_path + "branches", wc_path + "trunk/vendor"
    svn :commit, wc_path, "--message", "'first commit'"
  end

  def test_import
    piston :import, "http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement/", wc_path + "trunk/vendor/ssl_requirement"

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
end
