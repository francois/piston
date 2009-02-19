Given /^a newly created Subversion project$/ do
  @reposdir = Tmpdir.where(:repos)
  @reposdir.mkpath
  svnadmin :create, @reposdir 
  @wcdir = Tmpdir.where(:wc)
  svn :checkout, "file:///#{@reposdir}", @wcdir
end

Given /^a remote Subversion project named (\w+)$/ do |name|
  @remotereposdir = Tmpdir.where("#{name}/repos")
  @remotereposdir.mkpath
  svnadmin :create, @remotereposdir
  @remotewcdir = Tmpdir.where("#{name}/wc")
  svn :checkout, "file:///#{@remotereposdir}", @remotewcdir
end
 
Given /^a file named ([^\s]+) with content "([^"]+)" in remote (\w+) project$/ do |filename, content, project|
  content.gsub!("\\n", "\n")
  File.open(@remotewcdir + filename, "w+") {|io| io.puts(content)}
  svn :add, @remotewcdir + filename
  svn :commit, "--message", "adding #{filename}", @remotewcdir
end

When /^I import ([\w]+)$/ do |project|
  Dir.chdir(@wcdir) do
    cmd = "#{Tmpdir.piston} import file://#{@remotereposdir} 2>&1"
    STDERR.puts cmd.inspect if $DEBUG
    @stdout = `#{cmd}`
    STDERR.puts @stdout if $DEBUG
  end
end

Then /^I should see "([^"]+)"$/ do |regexp|
  re = Regexp.new(regexp, Regexp::IGNORECASE + Regexp::MULTILINE)
  @stdout.should =~ re
end
