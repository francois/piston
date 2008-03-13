$:.unshift File.dirname(__FILE__) + "/../../piston-core/lib"

require "test/unit"
require "rubygems"
require "mocha"
require "logger"

require "piston/svn/repository"
require "piston/repository" # Part of piston-core
require "piston/svn/working_copy"
require "piston/working_copy" # Part of piston-core
require "piston/svn/revision"
require "piston/revision" # Part of piston-core

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
  Test::Unit::TestCase.logger
