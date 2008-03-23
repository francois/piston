require "rake/testtask"

namespace :test do
  Rake::TestTask.new("units") do |t|
    t.libs << "test"
    t.test_files = FileList['test/unit/**/test_*.rb']
    t.verbose = true
    t.warning = true
  end
end
