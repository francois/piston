require "rubygems"
require "test/unit"
require "mocha"
require "logger"

require "piston/commands/base"
require "piston/repository"
require "piston/working_copy"

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

module Test
  module Unit
    class TestCase
      class << self
        def logger
          @@logger ||= Logger.new("log/test.log")
        end
      end

      def logger
        self.class.logger
      end
    end
  end
end

Pathname.new(File.dirname(__FILE__) + "/../log").mkdir rescue nil
Piston::WorkingCopy.logger =
  Piston::Repository.logger =
  Piston::Commands::Base.logger =
  Test::Unit::TestCase.logger
