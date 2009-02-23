Given /^a newly created Git project$/ do
  @wcdir = Tmpdir.where(:wc)
  @wcdir.mkpath
  Dir.chdir(@wcdir) do
    git :init
    touch :README
    git :add, "."
    stdout = git :commit, "--message", "first commit"
    stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]+/
  end
end

Given /^a newly created Subversion project$/ do
  @reposdir = Tmpdir.where(:repos)
  @reposdir.mkpath
  svnadmin :create, @reposdir 
  @wcdir = Tmpdir.where(:wc)
  svn :checkout, "file:///#{@reposdir}", @wcdir
end

Given /^a remote Git project named (\w+)$/ do |name|
  @remotewcdir = @remotereposdir = Tmpdir.where("remote/#{name}.git")
  @remotereposdir.mkpath
  Dir.chdir(@remotereposdir) do
    git :init
    touch :README
    git :add, "."
    stdout = git :commit, "--message", "initial commit"
    stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]+/
  end
end

Given /^a remote Subversion project named (\w+)( using the classic layout)?$/ do |name, classic|
  @remotereposdir = Tmpdir.where("remote/repos/#{name}")
  @remotereposdir.mkpath
  svnadmin :create, @remotereposdir
  @remotewcdir = Tmpdir.where("remote/wc/#{name}")
  svn :checkout, "file:///#{@remotereposdir}", @remotewcdir
  if classic then
    svn :mkdir, @remotewcdir + "trunk", @remotewcdir + "branches", @remotewcdir + "tags"
    stdout = svn :commit, "--message", "classic layout", @remotewcdir
    stdout.should =~ /Committed revision \d+/
    @remotewcdir    = @remotewcdir + "trunk"
    @remotereposdir = @remotereposdir + "trunk"
  end
end
 
Given /^a file named ([^\s]+) was deleted in remote (\w+) project$/ do |filename, project|
  Dir.chdir(@remotewcdir) do
    if (@remotewcdir + ".git").directory? then
      git :rm, filename
      stdout = git :commit, "--message", "removing #{filename}"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]+/
    else
      svn :rm, filename
      stdout = svn :commit, "--message", "removing #{filename}"
      stdout.should =~ /Committed revision \d+/
    end
  end
end

Given /^a file named ([^\s]+) with content "([^"]+)" in remote (\w+) project$/ do |filename, content, project|
  content.gsub!("\\n", "\n")
  File.open(@remotewcdir + filename, "w+") {|io| io.puts(content)}
  Dir.chdir(@remotewcdir) do
    if (@remotewcdir + ".git").directory? then
      git :add, "."
      stdout = git :commit, "--message", "adding #{filename}"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]/
    else
      svn :add, filename
      stdout = svn :commit, "--message", "adding #{filename}"
      stdout.should =~ /Committed revision \d+/
    end
  end
end

Given /^a file named ([^\s]+) was renamed to ([^\s]+) in remote (\w+) project$/ do |from, to, project|
  Dir.chdir(@remotewcdir) do
    if (@remotewcdir + ".git").directory? then
      git :mv, from, to
      stdout = git :commit, "--message", "moved #{from} to #{to}"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]/
    else
      svn :mv, from, to
      stdout = svn :commit, "--message", "moved #{from} to #{to}"
      stdout.should =~ /Committed revision \d+/
    end
  end
end

Given /^a file named ([^\s]+) was updated with "([^"]+)" in remote (\w+) project$/ do |filename, content, project|
  content.gsub!("\\n", "\n")
  File.open(@remotewcdir + filename, "w+") {|io| io.puts(content)}
  Dir.chdir(@remotewcdir) do
    if (@remotewcdir + ".git").directory? then
      git :add, "."
      stdout = git :commit, "--message", "updating #{filename}"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]/
    else
      stdout = svn :commit, "--message", "updating #{filename}"
      stdout.should =~ /Committed revision \d+/
    end
  end
end

Given /^I changed ([\w\/.]+) to "([^"]+)"$/ do |filename, content|
  content.gsub!("\\n", "\n")
  File.open(@wcdir + filename, "w+") {|io| io.puts(content)}
  Dir.chdir(@wcdir) do
    if (@wcdir + ".git").directory? then
      git :add, "."
      stdout = git :commit, "--message", "adding #{filename}"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]/
    else
      stdout = svn :commit, "--message", "adding #{filename}"
      stdout.should =~ /Committed revision \d+/
    end
  end
end

Given /^an existing ([\w\/]+) folder$/ do |name|
  if (@wcdir + ".git").directory? then
    (@wcdir + "vendor").mkpath
    touch(@wcdir + "vendor/.gitignore")
    Dir.chdir(@wcdir) do
      git :add, "."
      stdout = git :commit, "--message", "registered #{name}/"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]+/
    end
  else
    svn :mkdir, @wcdir + name
    stdout = svn :commit, "--message", "creating #{name}", @wcdir
    stdout.should =~ /Committed revision \d+/
  end
end

When /^I import(?:ed)? ([\w\/]+)(?: into ([\w\/]+))?$/ do |project, into|
  Dir.chdir(@wcdir) do
    cmd = "#{Tmpdir.piston} import --verbose 5 file://#{@remotereposdir} 2>&1"
    cmd << " #{into}" if into
    STDERR.puts cmd.inspect if $DEBUG
    @stdout = `#{cmd}`
    STDERR.puts @stdout if $DEBUG
  end
end

When /^I update(?:ed)? ([\w\/]+)$/ do |path|
  Dir.chdir(@wcdir) do
    cmd = "#{Tmpdir.piston} update --verbose 5 #{@wcdir + path}  2>&1"
    STDERR.puts cmd.inspect if $DEBUG
    @stdout = `#{cmd}`
    STDERR.puts @stdout if $DEBUG
  end
end

When /^I committed$/ do
  if (@wcdir + ".git").directory?
    Dir.chdir(@wcdir) do
      stdout = git :commit, "--message", "commit", "--all"
      stdout.should =~ /Created (?:initial )?commit [a-fA-F0-9]+/
    end
  else
    stdout = svn(:commit, "--message", "commit", @wcdir)
    stdout.should =~ /Committed revision \d+/
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

Then /^I should (not )?find a ([.\w+\/]+) file$/ do |not_find, name|
  if not_find then
    File.exist?(@wcdir + name).should be_false
    File.file?(@wcdir + name).should be_false
  else
    File.exist?(@wcdir + name).should be_true
    File.file?(@wcdir + name).should be_true
  end
end

Then /^I should find "([^"]+)" in ([\w\/.]+)$/ do |content, path|
  File.read(@wcdir + path).should =~ Regexp.new(content, Regexp::MULTILINE + Regexp::IGNORECASE)
end
