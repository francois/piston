require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestGitGit < Piston::TestCase
  attr_reader :root_path, :parent_path, :wc_path

  def setup
    super
    @root_path = mkpath("tmp/import_git_git")

    @parent_path = root_path + "parent"
    mkpath(parent_path)

    @wc_path = root_path + "wc"
    mkpath(wc_path)

    Dir.chdir(parent_path) do
      git(:init)
      File.open("README", "wb") {|f| f.write "Readme - first commit\n"}
      File.open("file_in_first_commit", "wb") {|f| f.write "file_in_first_commit"}
      File.open("file_to_rename", "wb") {|f| f.write "file_to_rename"}
      File.open("file_to_copy", "wb") {|f| f.write "file_to_copy"}
      File.open("conflicting_file", "wb") {|f| f.write "conflicting_file\n"}
      git(:add, ".")
      git(:commit, "-m", "'first commit'")
    end

    Dir.chdir(wc_path) do
      git(:init)
      File.open("README", "wb") {|f| f.write "Hello World!"}
      Pathname.new("vendor").mkdir
      File.open("vendor/.gitignore", "wb") {|f| f.write "*.swp"}
      git(:add, ".")
      git(:commit, "-m", "'first commit'")
    end
  end

  def test_import
    Dir.chdir(wc_path) do
      piston(:import, parent_path, "vendor/parent")
    end

    Dir.chdir(wc_path) do
      assert_equal IMPORT_STATUS.split("\n").sort, git(:status).split("\n").sort
    end

    info = YAML.load_file(wc_path + "vendor/parent/.piston.yml")
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
#\tnew file:   vendor/parent/file_to_rename
#\tnew file:   vendor/parent/file_to_copy
#\tnew file:   vendor/parent/conflicting_file
#
)

  def test_update
    Dir.chdir(wc_path) do
      piston(:import, parent_path, "vendor/parent")
      git(:commit, "-m", "'import'")
    end

    File.open(wc_path + "vendor/parent/README", "wb") do |f|
      f.write "Readme - modified after imported\nReadme - first commit\n"
    end
    File.open(wc_path + "vendor/parent/conflicting_file", "ab") do |f|
      f.write "working copy\n"
    end
    Dir.chdir(wc_path) do
      git(:add, ".")
      git(:commit, "-m", "'next commit'")
    end

    Dir.chdir(parent_path) do
      File.open("README", "ab") {|f| f.write "Readme - second commit\n"}
      File.open("conflicting_file", "ab") {|f| f.write "parent repository\n"}
      git(:rm, "file_in_first_commit")
      File.open("file_in_second_commit", "wb") {|f| f.write "file_in_second_commit"}
      FileUtils.cp("file_to_copy", "copied_file")
      git(:mv, "file_to_rename", "renamed_file")
      git(:add, ".")
      git(:commit, "-m", "'second commit'")
    end

    Dir.chdir(wc_path) do
      piston(:update, "vendor/parent")
    end

    Dir.chdir(wc_path) do
      assert_equal CHANGE_STATUS.split("\n"), git(:status).split("\n")
    end
    assert_equal README, File.read(wc_path + "vendor/parent/README")
    assert_match CONFLICT, File.read(wc_path + "vendor/parent/conflicting_file")
  end

  CHANGE_STATUS = %Q(vendor/parent/conflicting_file: needs merge
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#\tmodified:   vendor/parent/.piston.yml
#\tmodified:   vendor/parent/README
#\tnew file:   vendor/parent/copied_file
#\tdeleted:    vendor/parent/file_in_first_commit
#\tnew file:   vendor/parent/file_in_second_commit
#\trenamed:    vendor/parent/file_to_rename -> vendor/parent/renamed_file
#
# Changed but not updated:
#   (use "git add <file>..." to update what will be committed)
#
#\tunmerged:   vendor/parent/conflicting_file
#\tmodified:   vendor/parent/conflicting_file
#
)
  README = %Q(Readme - modified after imported
Readme - first commit
Readme - second commit
)
  CONFLICT = /conflicting_file
<<<<<<< HEAD:#{Regexp.quote('vendor/parent/conflicting_file')}
working copy
=======
parent repository
>>>>>>> my-[0-9a-f]{40}:#{Regexp.quote('vendor/parent/conflicting_file')}
/

  def test_double_update
    Dir.chdir(wc_path) do
      piston(:import, parent_path, "vendor/parent")
      git(:commit, "-m", "'import'")
    end

    File.open(wc_path + "vendor/parent/conflicting_file", "wb") do |f|
      f.write "modified after imported\n"
    end
    Dir.chdir(wc_path) do
      git(:add, ".")
      git(:commit, "-m", "'next commit'")
    end

    Dir.chdir(parent_path) do
      File.open("file_in_first_commit", "ab") {|f| f.write "\nmodified in parent repository\n"}
      git(:add, ".")
      git(:commit, "-m", "'second commit'")
    end

    Dir.chdir(wc_path) do
      piston(:update, "vendor/parent")
      git(:commit, "-m", "'updated'")
    end

    Dir.chdir(parent_path) do
      File.open("conflicting_file", "ab") {|f| f.write "modified in parent repository\n"}
      git(:add, ".")
      git(:commit, "-m", "'third commit'")
    end
    Dir.chdir(wc_path) do
      piston(:update, "vendor/parent")
    end

    Dir.chdir(wc_path) do
      # It isn't implemented, unmerge status should be copied from temp dir to working copy
      #assert_equal DOUBLE_CHANGE_STATUS.split("\n"), git(:status).split("\n")
      # Use this assert so test doesn't fail while port conflicts is not implemented
      assert_equal DOUBLE_CHANGE_STATUS_NO_UNMERGED.split("\n"), git(:status).split("\n")
    end
    assert_equal DOUBLE_CONFLICT, File.read(wc_path + "vendor/parent/conflicting_file")
  end
  DOUBLE_CHANGE_STATUS = %Q(vendor/parent/conflicting_file: needs merge
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#\tmodified:   vendor/parent/.piston.yml
#
# Changed but not updated:
#   (use "git add <file>..." to update what will be committed)
#
#\tunmerged:   vendor/parent/conflicting_file
#\tmodified:   vendor/parent/conflicting_file
#
)
  DOUBLE_CHANGE_STATUS_NO_UNMERGED = %Q(# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#\tmodified:   vendor/parent/.piston.yml
#\tmodified:   vendor/parent/conflicting_file
#
)
  DOUBLE_CONFLICT = %Q(<<<<<<< HEAD:conflicting_file
modified after imported
=======
conflicting_file
modified in parent repository
>>>>>>> master:conflicting_file
)
end
