require "test/unit"
require "rubygems"
require "mocha"
require "log4r"
require "fileutils"
require "piston"
require "active_support"

begin
  require "turn"
rescue LoadError
  # NOP: ignore, this is not a real dependency
end

require File.expand_path("#{File.dirname(__FILE__)}/integration_helpers")
require "find"

module Test
  module Unit
    module Assertions
      def deny(boolean, message = nil)
        message = build_message message, '<?> is not false or nil.', boolean
        assert_block message do
          not boolean
        end
      end
    end
  end
end

class Piston::TestCase < Test::Unit::TestCase
  class << self
    def logger
      @@logger ||= Log4r::Logger["test"]
    end
  end
  
  attr_reader :pathnames
  def setup
    super
    @pathnames = []
  end

  def teardown
    pathnames.each do |pathname|
      pathname.rmtree if File.exists?(pathname)
    end
    super
  end

  def run(*args)
    return if method_name.to_sym == :default_test && self.class == Piston::TestCase
    super
  end

  def mkpath(path_or_pathname)
    returning(path_or_pathname.is_a?(Pathname) ? path_or_pathname : Pathname.new(File.expand_path(path_or_pathname))) do |path|
      path.mkpath
      pathnames.push(path)
    end
  end

  def logger
    self.class.logger
  end
end

LOG_DIR = Pathname.new(File.expand_path("#{File.dirname(__FILE__)}/../log")) unless Object::const_defined?(:LOG_DIR)
LOG_DIR.mkdir rescue nil

Log4r::Logger.root.level = Log4r::DEBUG

Log4r::Logger.new("main")
Log4r::Logger.new("handler")
Log4r::Logger.new("handler::client")
Log4r::Logger.new("handler::client::out")
Log4r::Logger.new("test")

FileUtils.touch("#{LOG_DIR}/test.log")
Log4r::FileOutputter.new("log", :trunc => true, :filename => (LOG_DIR + "test.log").realpath.to_s)

Log4r::Logger["main"].add "log"
Log4r::Logger["handler"].add "log"
Log4r::Logger["test"].add "log"
