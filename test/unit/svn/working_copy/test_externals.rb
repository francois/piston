require File.dirname(__FILE__) + "/../../../test_helper"

class TestWorkingCopyExternals < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
  end

  def test_parse_empty_svn_externals
    @wc.stubs(:svn).returns(EMPTY_EXTERNALS)
    assert_equal({}, @wc.externals)
  end

  def test_parse_simple_externals
    @wc.stubs(:svn).returns(SIMPLE_RAILS_EXTERNALS)
    assert_equal({@wcdir + "vendor/rails" => {:revision => "HEAD", :url => "http://dev.rubyonrails.org/svn/rails/trunk"}}, @wc.externals)
  end

  def test_parse_externals_with_revision
    @wc.stubs(:svn).returns(VERSIONED_RAILS_EXTERNALS)
    assert_equal({@wcdir + "vendor/rails" => {:revision => 8726, :url => "http://dev.rubyonrails.org/svn/rails/trunk"}}, @wc.externals)
  end

  EMPTY_EXTERNALS = ""
  SIMPLE_RAILS_EXTERNALS = <<EOF
  Properties on 'vendor':
    svn:externals : rails http://dev.rubyonrails.org/svn/rails/trunk

EOF
  VERSIONED_RAILS_EXTERNALS = <<EOF
  Properties on 'vendor':
    svn:externals : rails -r8726 http://dev.rubyonrails.org/svn/rails/trunk

EOF
end
