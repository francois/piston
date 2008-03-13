$:.unshift File.dirname(__FILE__) + "/../../piston-core/lib"

require "test/unit"
require "rubygems"
require "mocha"
require "piston/svn/repository"
require "piston/repository" # Part of piston-core
require "piston/svn/working_copy"
require "piston/working_copy" # Part of piston-core

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
