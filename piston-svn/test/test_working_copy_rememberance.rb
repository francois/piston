require File.dirname(__FILE__) + "/test_helper"
require "pathname"

class TestWorkingCopyCopying < Test::Unit::TestCase
  include Piston::Svn::Client

  def setup
    @reposdir = Pathname.new("tmp/repos")
    svnadmin :create, @reposdir

    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def teardown
    @reposdir.rmtree rescue nil
    @wcdir.rmtree rescue nil
  end

  def test_transforms_each_hash_pair_into_svn_properties
    values = {"piston:a" => "a", "piston:b" => "b"}
    @wc.expects(:svn).with(:propset, "piston:a", "a", @wcdir)
    @wc.expects(:svn).with(:propset, "piston:b", "b", @wcdir)
    @wc.remember(values)
  end
end
