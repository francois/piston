require "rake/testtask"

namespace :test do
  Rake::TestTask.new("units") do |t|
    t.libs << "test"
    t.test_files = FileList['test/unit/**/test_*.rb']
    t.verbose = true
    t.warning = false
  end

  Rake::TestTask.new("integration") do |t|
    t.libs << "test"
    t.test_files = FileList['test/integration/**/test_*.rb']
    t.verbose = true
    t.warning = false
  end

  Rake::TestTask.new("recent") do |t|
    t.libs << "test"
    t.verbose = true
    t.warning = false

    # 10 minutes ago
    cutoff_at = Time.now - 10 * 60

    t.test_files = FileList["test/integration/**/test_*.rb", "test/unit/**/test_*.rb"].select do |path|
      File.mtime(path) > cutoff_at
    end
  end

  desc "Prepares an SVN and Git repository for manual testing"
  task :prep do
    require "pathname"
    PISTON_ROOT = Pathname.new(File.expand_path(Dir.pwd))
    MANUAL_ROOT = PISTON_ROOT + "tmp/manual"
    rm_rf MANUAL_ROOT; mkdir MANUAL_ROOT
    REPOS_ROOT = MANUAL_ROOT + "repos"
    REPOS_URL = "file://#{REPOS_ROOT}"
    WC_ROOT = MANUAL_ROOT + "wc"

    sh "svnadmin create #{REPOS_ROOT}"
    sh "svn checkout #{REPOS_URL} #{WC_ROOT}"
    Dir.chdir(WC_ROOT) do
      sh "svn mkdir project plugins plugins/libcalc plugins/libpower"
      Dir.chdir("plugins/libcalc") do
        File.open("README", "w") {|io| io.puts "libcalc\n-------\n\nThis is libcalc\n"}
        File.open("libcalc.rb", "w") {|io| io.puts "# libcaclc.rb\n# Ensure this is powerful enough\n"}
      end
      Dir.chdir("plugins/libpower") do
        File.open("README", "w") {|io| io.puts "libpower\n-------\n\nThis is libpower\n"}
      end
      sh "svn add plugins/libcalc/README plugins/libcalc/libcalc.rb plugins/libpower/README"
      sh "svn commit -m 'Initial revision'"
      sh "ruby -I#{PISTON_ROOT}/lib #{PISTON_ROOT}/bin/piston import #{REPOS_URL}"
      Dir.chdir("plugins/libcalc") do
        File.open("libcalc.rb", "w") {|io| io.puts "# libcalc.rb\n# Ensure this is powerful enough\n\nclass Libcalc\nend\n"}
      end
      sh "svn commit -m 'Implement libcalc'"
    end
  end
end
