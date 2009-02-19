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
    @remotewcdir    = @remotewcdir + "trunk"
    @remotereposdir = @remotereposdir + "trunk"
  end
end
 
Given /^a file named ([^\s]+) with content "([^"]+)" in remote (\w+) project$/ do |filename, content, project|
  content.gsub!("\\n", "\n")
  File.open(@remotewcdir + filename, "w+") {|io| io.puts(content)}
  svn :add, @remotewcdir + filename
  svn :commit, "--message", "adding #{filename}", @remotewcdir
end

When /^I import ([\w\/]+)(?: into ([\w\/]+))?$/ do |project, into|
  Dir.chdir(@wcdir) do
    cmd = "#{Tmpdir.piston} import --verbose 5 file://#{@remotereposdir} 2>&1"
    cmd << " #{into}" if into
    STDERR.puts cmd.inspect if $DEBUG
    @stdout = `#{cmd}`
    STDERR.puts @stdout if $DEBUG
  end
end

Then /^I should see "([^"]+)"(\s+debug)?$/ do |regexp, debug|
  re = Regexp.new(regexp, Regexp::IGNORECASE + Regexp::MULTILINE)
  STDERR.puts @stdout if debug
  @stdout.should =~ re
end

Then /^I should( not)? find a ([\w+\/]+) folder$/ do |not_find, name|
  if not_find then
    File.exist?(@wcdir + name).should_not be_true
    File.directory?(@wcdir + name).should_not be_true
  else
    File.exist?(@wcdir + name).should be_true
    File.directory?(@wcdir + name).should be_true
  end
end

Then /^I should find a ([.\w+\/]+) file$/ do |name|
  File.exist?(@wcdir + name).should be_true
  File.file?(@wcdir + name).should be_true
end
