require File.expand_path("#{File.dirname(__FILE__)}/../../../test_helper")

class Piston::Svn::TestWorkingCopyExternals < PistonTestCase
  def setup
    super
    @wcdir = mkpath("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
  end

  def test_parse_empty_svn_externals
    @wc.stubs(:svn).returns(EMPTY_EXTERNALS)
    assert_equal({}, @wc.externals)
  end

  def test_parse_simple_externals
    @wc.stubs(:svn).returns(SIMPLE_RAILS_EXTERNALS)
    assert_equal({@wcdir + "vendor/rails" => {:revision => :head, :url => "http://dev.rubyonrails.org/svn/rails/trunk"}}, @wc.externals)
  end

  def test_parse_externals_with_revision
    @wc.stubs(:svn).returns(VERSIONED_RAILS_EXTERNALS)
    assert_equal({@wcdir + "vendor/rails" => {:revision => 8726, :url => "http://dev.rubyonrails.org/svn/rails/trunk"}}, @wc.externals)
  end

  def test_parse_externals_with_long_revision
    @wc.stubs(:svn).returns(LONG_VERSION_RAILS_EXTERNALS)
    assert_equal({@wcdir + "vendor/rails" => {:revision => 8726, :url => "http://dev.rubyonrails.org/svn/rails/trunk"}}, @wc.externals)
  end

  def test_remove_external_references_calls_svn_propdel
    @wc.expects(:svn).with(:propdel, "svn:externals", @wcdir+"vendor")
    @wc.remove_external_references(@wcdir+"vendor")
  end

  def test_remove_external_references_calls_svn_propdel_with_multiple_dirs
    @wc.expects(:svn).with(:propdel, "svn:externals", @wcdir+"vendor", @wcdir+"vendor/plugins")
    @wc.remove_external_references(@wcdir+"vendor", @wcdir+"vendor/plugins")
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
  LONG_VERSION_RAILS_EXTERNALS = <<EOF
  Properties on 'vendor':
    svn:externals : rails --revision 8726 http://dev.rubyonrails.org/svn/rails/trunk

EOF
end
