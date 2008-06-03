require File.dirname(__FILE__) + "/../test_helper"
require File.dirname(__FILE__) + "/../integration_helpers"

class TestImportGitSvn < Test::Unit::TestCase
  attr_reader :root_path, :repos_path, :wc_path

  def setup
    @root_path = Pathname.new("/tmp/import_git_svn")
    @repos_path = @root_path + "repos"
    @wc_path = @root_path + "wc"

    root_path.rmtree rescue nil
    root_path.mkpath

    svnadmin :create, repos_path
    svn :checkout, "file://#{repos_path}", wc_path
    svn :mkdir, wc_path + "trunk", wc_path + "tags", wc_path + "branches", wc_path + "trunk/vendor"
    svn :commit, wc_path, "--message", "'first commit'"
  end

  def teardown
    root_path.rmtree rescue nil
  end

  def test_import
    piston(:import, "git://github.com/technoweenie/attachment_fu.git", wc_path + "trunk/vendor/attachment_fu")

    assert_equal ADD_STATUS.split("\n").sort, svn(:status, wc_path + "trunk/vendor").gsub((wc_path + "trunk/").to_s, "").split("\n").sort

    info = YAML.load(File.read(wc_path + "trunk/vendor/attachment_fu/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal "git://github.com/technoweenie/attachment_fu.git", info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    response = `git-ls-remote git://github.com/technoweenie/attachment_fu.git`
    head_commit = response.grep(/HEAD/).first.chomp.split(/\s+/).first
    assert_equal head_commit, info["handler"][Piston::Git::COMMIT]
  end

  def test_import_from_branch
    piston(:import, "--revision", "origin/rewrite", "git://github.com/technoweenie/attachment_fu.git", wc_path + "trunk/vendor/attachment_fu")

    assert File.directory?(wc_path + "trunk/vendor/attachment_fu/vendor"),
        "Could not find vendor director in attachment_fu imported directory: please check that there still exists a rewrite branch on GitHub AND that the rewrite branch has a vendor/ directory."

    info = YAML.load(File.read(wc_path + "trunk/vendor/attachment_fu/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal "git://github.com/technoweenie/attachment_fu.git", info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    response = `git-ls-remote git://github.com/technoweenie/attachment_fu.git`
    head_commit = response.grep(/refs\/heads\/rewrite/).first.chomp.split(/\s+/).first
    assert_equal head_commit, info["handler"][Piston::Git::COMMIT]
    assert_equal "origin/rewrite", info["handler"][Piston::Git::BRANCH]
  end

  def test_import_from_tag
    piston(:import, "--revision", "1.9.1", "git://github.com/francois/piston.git", wc_path + "trunk/vendor/piston")

    info = YAML.load(File.read(wc_path + "trunk/vendor/piston/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal "git://github.com/francois/piston.git", info["repository_url"]
    assert_equal "Piston::Git::Repository", info["repository_class"]

    assert_equal "684301c8b5cc1c95fe1568fb80e8f4da20c2a235", info["handler"][Piston::Git::COMMIT]
    assert_equal "1.9.1", info["handler"][Piston::Git::BRANCH]
  end

  ADD_STATUS = %Q(A      vendor/attachment_fu
A      vendor/attachment_fu/test
A      vendor/attachment_fu/test/test_helper.rb
A      vendor/attachment_fu/test/processors
A      vendor/attachment_fu/test/processors/mini_magick_test.rb
A      vendor/attachment_fu/test/processors/core_image_test.rb
A      vendor/attachment_fu/test/processors/image_science_test.rb
A      vendor/attachment_fu/test/processors/gd2_test.rb
A      vendor/attachment_fu/test/processors/rmagick_test.rb
A      vendor/attachment_fu/test/basic_test.rb
A      vendor/attachment_fu/test/schema.rb
A      vendor/attachment_fu/test/database.yml
A      vendor/attachment_fu/test/base_attachment_tests.rb
A      vendor/attachment_fu/test/fixtures
A      vendor/attachment_fu/test/fixtures/files
A      vendor/attachment_fu/test/fixtures/files/foo.txt
A      vendor/attachment_fu/test/fixtures/files/fake
A      vendor/attachment_fu/test/fixtures/files/fake/rails.png
A      vendor/attachment_fu/test/fixtures/files/rails.png
A      vendor/attachment_fu/test/fixtures/attachment.rb
A      vendor/attachment_fu/test/backends
A      vendor/attachment_fu/test/backends/file_system_test.rb
A      vendor/attachment_fu/test/backends/db_file_test.rb
A      vendor/attachment_fu/test/backends/remote
A      vendor/attachment_fu/test/backends/remote/s3_test.rb
A      vendor/attachment_fu/test/validation_test.rb
A      vendor/attachment_fu/test/extra_attachment_test.rb
A      vendor/attachment_fu/test/geometry_test.rb
A      vendor/attachment_fu/Rakefile
A      vendor/attachment_fu/init.rb
A      vendor/attachment_fu/lib
A      vendor/attachment_fu/lib/technoweenie
A      vendor/attachment_fu/lib/technoweenie/attachment_fu
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/processors
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/mini_magick_processor.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/core_image_processor.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/image_science_processor.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/gd2_processor.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/rmagick_processor.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/backends
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/backends/file_system_backend.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/backends/db_file_backend.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu/backends/s3_backend.rb
A      vendor/attachment_fu/lib/technoweenie/attachment_fu.rb
A      vendor/attachment_fu/lib/geometry.rb
A      vendor/attachment_fu/CHANGELOG
A      vendor/attachment_fu/amazon_s3.yml.tpl
A      vendor/attachment_fu/install.rb
A      vendor/attachment_fu/.piston.yml
A      vendor/attachment_fu/vendor
A      vendor/attachment_fu/vendor/red_artisan
A      vendor/attachment_fu/vendor/red_artisan/core_image
A      vendor/attachment_fu/vendor/red_artisan/core_image/processor.rb
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters/watermark.rb
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters/color.rb
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters/effects.rb
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters/scale.rb
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters/quality.rb
A      vendor/attachment_fu/vendor/red_artisan/core_image/filters/perspective.rb
A      vendor/attachment_fu/README
)
end
