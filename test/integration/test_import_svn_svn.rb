require File.dirname(__FILE__) + "/../test_helper"
require File.dirname(__FILE__) + "/../integration_helpers"

class TestImportSvnSvn < Test::Unit::TestCase
  attr_reader :repos_path, :wc_path

  def setup
    @repos_path = PISTON_ROOT + "tmp/import_real/repos"
    @wc_path = PISTON_ROOT + "tmp/import_real/wc"

    repos_path.parent.rmtree rescue nil
    repos_path.parent.mkpath
  end

  def teardown
    repos_path.parent.rmtree rescue nil
  end

  def test_import
    svnadmin :create, repos_path
    svn :checkout, "file://#{repos_path}", wc_path
    svn :mkdir, wc_path + "trunk", wc_path + "tags", wc_path + "branches", wc_path + "trunk/vendor"
    svn :commit, wc_path, "--message", "'first commit'"
    piston :import, "http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement/", wc_path + "trunk/vendor/ssl_requirement"

    assert_equal "A      vendor/ssl_requirement
A      vendor/ssl_requirement/test
A      vendor/ssl_requirement/test/ssl_requirement_test.rb
A      vendor/ssl_requirement/lib
A      vendor/ssl_requirement/lib/ssl_requirement.rb
A      vendor/ssl_requirement/.piston.yml
A      vendor/ssl_requirement/README
".split.sort, svn(:status, wc_path + "trunk/vendor/").gsub((wc_path + "trunk/").to_s, "").split.sort

    info = YAML.load(File.read(wc_path + "trunk/vendor/ssl_requirement/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal "http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement", info["handler"][Piston::Svn::ROOT]
    assert_equal "5ecf4fe2-1ee6-0310-87b1-e25e094e27de", info["handler"][Piston::Svn::UUID]
  end
end
