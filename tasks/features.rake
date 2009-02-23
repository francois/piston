require "cucumber/rake/task"

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = "--no-source"
  t.feature_list  = FileList["features/*.feature"]
end
