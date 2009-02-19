Given /^a newly created Subversion project$/ do
  @tmpdir = Pathname.new(ENV["TMPDIR"] || ENV["TMP"] || "tmp") + "repos"
  @tmpdir.mkpath
  svnadmin(:create, @tmpdir)
  svn(:checkout, "file:///#{@tmpdir.realpath}")
end

#Given /^a remote Subversion project named (\w+)$/ do |name|
#end
#
#When /^I run "(.*)"$/ do |command|
#end
#
#Then /^I should see "(.*)"$/ do |regexp|
#end
#
#Then /^I should find a ([\w\/]+) folder$/ do |path|
#end
