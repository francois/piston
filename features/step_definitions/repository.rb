Given /^a newly created Subversion project$/ do
  @reposdir = Tmpdir.where(:repos)
  svnadmin :create, @reposdir 
  svn :checkout, "file:///#{@reposdir.realpath}", Tmpdir.where(:wc)
end

Given /^a remote Subversion project named (\w+)$/ do |name|
  @remotereposdir = Tmpdir.where("#{name}/repos")
  @remotereposdir.mkpath
  svnadmin :create, @remotereposdir
  svn :checkout, "file:///#{@remotereposdir.realpath}", Tmpdir.where("#{name}/wc")
end
