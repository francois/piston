require "test/unit"
require "rubygems"
require "mocha"
require "log4r"
require "fileutils"

require File.dirname(__FILE__) + "/../config/requirements"

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

    class TestCase
      class << self
        def logger
          @@logger ||= Log4r::Logger["test"]
        end
      end

      def logger
        self.class.logger
      end
    end
  end
end

LOG_DIR = Pathname.new(File.dirname(__FILE__) + "/../log") unless Object::const_defined?(:LOG_DIR)
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

def turn_methods_public(classe, method_name = nil)
  if method_name
    classe.class_eval do
      public method_name
    end
  else
    turn_all_methods_public classe
  end
end

def turn_all_methods_public(classe)
  classe.class_eval do
    private_instance_methods.each { |instance_method| public instance_method }
    private_methods.each { |method| public_class_method method } 
    protected_instance_methods.each { |instance_method| public instance_method }
    protected_methods.each { |method| public_class_method method } 
  end  
end

