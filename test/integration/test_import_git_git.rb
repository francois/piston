require File.dirname(__FILE__) + "/../test_helper"
require File.dirname(__FILE__) + "/../integration_helpers"

class TestImportGitGit < Test::Unit::TestCase
  attr_reader :root_path, :repos_path, :wc_path

  def setup
    @root_path = Pathname.new("/tmp/import_git_git")
    @wc_path = @root_path + "wc"

    root_path.rmtree rescue nil
    root_path.mkpath

    wc_path.mkpath
    Dir.chdir(wc_path) do
      git(:init)
      File.open(wc_path + "README", "wb") {|f| f.write "Hello World!"}
      (wc_path + "vendor").mkdir
      File.open(wc_path + "vendor/.gitignore", "wb") {|f| f.write "*.swp"}
      git(:add, ".")
      git(:commit, "-m", "'first commit'")
    end
  end

  def teardown
    root_path.rmtree rescue nil
  end

  def test_import
    piston(:import, "git://github.com/technoweenie/attachment_fu.git", wc_path + "vendor/attachment_fu")

    Dir.chdir(wc_path) do
      assert_equal STATUS.split("\n").sort, git(:status).split("\n").sort
    end

    info = YAML.load(File.read(wc_path + "vendor/attachment_fu/.piston.yml"))
    assert_equal 1, info["format"]
    assert_equal "git://github.com/technoweenie/attachment_fu.git", info["handler"][Piston::Git::URL]
    assert_equal "416fbb0017fa4ecaccfca4bcada592d694d532e1", info["handler"][Piston::Git::COMMIT]
  end

  STATUS = %Q(# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#\tnew file:   vendor/attachment_fu/.piston.yml
#\tnew file:   vendor/attachment_fu/CHANGELOG
#\tnew file:   vendor/attachment_fu/README
#\tnew file:   vendor/attachment_fu/Rakefile
#\tnew file:   vendor/attachment_fu/amazon_s3.yml.tpl
#\tnew file:   vendor/attachment_fu/init.rb
#\tnew file:   vendor/attachment_fu/install.rb
#\tnew file:   vendor/attachment_fu/lib/geometry.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/backends/db_file_backend.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/backends/file_system_backend.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/backends/s3_backend.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/core_image_processor.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/gd2_processor.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/image_science_processor.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/mini_magick_processor.rb
#\tnew file:   vendor/attachment_fu/lib/technoweenie/attachment_fu/processors/rmagick_processor.rb
#\tnew file:   vendor/attachment_fu/test/backends/db_file_test.rb
#\tnew file:   vendor/attachment_fu/test/backends/file_system_test.rb
#\tnew file:   vendor/attachment_fu/test/backends/remote/s3_test.rb
#\tnew file:   vendor/attachment_fu/test/base_attachment_tests.rb
#\tnew file:   vendor/attachment_fu/test/basic_test.rb
#\tnew file:   vendor/attachment_fu/test/database.yml
#\tnew file:   vendor/attachment_fu/test/extra_attachment_test.rb
#\tnew file:   vendor/attachment_fu/test/fixtures/attachment.rb
#\tnew file:   vendor/attachment_fu/test/fixtures/files/fake/rails.png
#\tnew file:   vendor/attachment_fu/test/fixtures/files/foo.txt
#\tnew file:   vendor/attachment_fu/test/fixtures/files/rails.png
#\tnew file:   vendor/attachment_fu/test/geometry_test.rb
#\tnew file:   vendor/attachment_fu/test/processors/core_image_test.rb
#\tnew file:   vendor/attachment_fu/test/processors/gd2_test.rb
#\tnew file:   vendor/attachment_fu/test/processors/image_science_test.rb
#\tnew file:   vendor/attachment_fu/test/processors/mini_magick_test.rb
#\tnew file:   vendor/attachment_fu/test/processors/rmagick_test.rb
#\tnew file:   vendor/attachment_fu/test/schema.rb
#\tnew file:   vendor/attachment_fu/test/test_helper.rb
#\tnew file:   vendor/attachment_fu/test/validation_test.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/filters/color.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/filters/effects.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/filters/perspective.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/filters/quality.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/filters/scale.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/filters/watermark.rb
#\tnew file:   vendor/attachment_fu/vendor/red_artisan/core_image/processor.rb
#
)
end
