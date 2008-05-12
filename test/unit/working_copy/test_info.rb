require File.dirname(__FILE__) + "/../../test_helper"

class TestWorkingCopyInfo < Test::Unit::TestCase
  
  GIT_VALUES = {"format"=>1, "handler"=>{"commit"=>"db9c7bddaa9c54bff48d64c56db2f89b2bcfa049"}, "repository_url"=>"git://gitorious.org/git-tmbundle/mainline.git", "lock"=>false, "repository_class"=>"Piston::Git::Repository"}
  SVN_VALUES = {"format"=>1, "handler"=>{"piston:remote-revision"=>9250, "piston:uuid"=>"5ecf4fe2-1ee6-0310-87b1-e25e094e27de"}, "repository_url"=>"http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement", "lock"=>nil, "repository_class"=>"Piston::Svn::Repository"}
  
  
  def setup
    
    wcdir = Pathname.new("tmp/wc")
    wcdir.rmtree rescue nil
    wcdir.mkpath
    @wc = Piston::WorkingCopy.new(wcdir)
    
  end
  
  def test_info_when_is_git_repository
    @wc.expects(:recall).returns(GIT_VALUES)
    assert_equal "+---------------------------Piston Info----------------------------------+\nDirectory: tmp/wc\nRepository type: Git\nRepository: git://gitorious.org/git-tmbundle/mainline.git\nCommit: db9c7bddaa9c54bff48d64c56db2f89b2bcfa049\nLock: false\n+------------------------------------------------------------------------+", @wc.info
  end
  
  def test_info_when_is_svn_repository
    @wc.expects(:recall).returns(SVN_VALUES)
    assert_equal "+---------------------------Piston Info----------------------------------+\nDirectory: tmp/wc\nRepository type: Svn\nRepository: http://dev.rubyonrails.org/svn/rails/plugins/ssl_requirement\nRemote Revision: 9250\nLock: \n+------------------------------------------------------------------------+", @wc.info    
  end
  

end
