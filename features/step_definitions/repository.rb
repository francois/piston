Given /^a newly created Subversion project$/ do
  @reposdir = Tmpdir.where(:repos)
  @reposdir.mkpath
  svnadmin :create, @reposdir 
  @wcdir = Tmpdir.where(:wc)
  svn :checkout, "file:///#{@reposdir}", @wcdir
end

Given /^a remote Subversion project named (\w+)( using the classic layout)?$/ do |name, classic|
  @remotereposdir = Tmpdir.where("remote/repos/#{name}")
  @remotereposdir.mkpath
  svnadmin :create, @remotereposdir
  @remotewcdir = Tmpdir.where("remote/wc/#{name}")
  svn :checkout, "file:///#{@remotereposdir}", @remotewcdir
  if classic then
    svn :mkdir, @remotewcdir + "trunk", @remotewcdir + "branches", @remotewcdir + "tags"
    svn :commit, "--message", "classic layout", @remotewcdir
    @removewcdir    = @remotewcdir + "trunk"
    @remotereposdir = @remotereposdir + "trunk"
  end
end
 
Given /^a file named ([^\s]+) with content "([^"]+)" in remote (\w+) project$/ do |filename, content, project|
  content.gsub!("\\n", "\n")
  File.open(@remotewcdir + filename, "w+") {|io| io.puts(content)}
  svn :add, @remotewcdir + filename
  svn :commit, "--message", "adding #{filename}", @remotewcdir
end

When /^I import ([\w\/]+)$/ do |project|
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

Then /^I should find a ([\w+\/]+) folder$/ do |name|
  File.exist?(@wcdir + name).should be_true
  File.directory?(@wcdir + name).should be_true
end

Then /^I should find a ([.\w+\/]+) file$/ do |name|
  File.exist?(@wcdir + name).should be_true
  File.file?(@wcdir + name).should be_true
end
