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
end

Rake::TestTask.new("test") do |t|
  Rake::Task["test:units"].invoke
  Rake::Task["test:integration"].invoke

  # Don't run the default test task
  exit 0
end
