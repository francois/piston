require File.dirname(__FILE__) + "/test_helper"

class TestSvnWorkingCopyRememberance < Test::Unit::TestCase
  def setup
    @wcdir = Pathname.new("tmp/wc")
    @wc = Piston::Svn::WorkingCopy.new(@wcdir)
    @wc.stubs(:svn)
    @wc.stubs(:svn).with(:info, anything).returns("a:b")
  end

  def teardown
    @wcdir.rmtree rescue nil
  end

  def test_remembers_hash_pairs_as_svn_propvalues
    values = {"piston:a" => "a", "piston:b" => "b"}
    @wc.expects(:svn).with(:propset, "piston:a", "a", @wcdir)
    @wc.expects(:svn).with(:propset, "piston:b", "b", @wcdir)
    @wc.remember(values)
  end

  def test_recalls_keys_as_svn_propvalues
    keys = %w(piston:a piston:b)
    @wc.expects(:svn).with(:propget, "piston:a", @wcdir).returns("a")
    @wc.expects(:svn).with(:propget, "piston:b", @wcdir).returns("b")
    values = {"piston:a" => "a", "piston:b" => "b"}
    assert_equal values, @wc.recall(keys)
  end
end
