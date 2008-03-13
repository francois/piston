require "piston/working_copy"
require "piston/svn/client"
require "uri"

module Piston
  module Svn
    class WorkingCopy < Piston::WorkingCopy
      extend Piston::Svn::Client

      class << self
        def understands_dir?(dir)
          result = svn(:info, dir) rescue :failed
          result == :failed ? false : true
        end
      end

      def svn(*args)
        self.class.svn(*args)
      end

      def svnadmin(*args)
        self.class.svnadmin(*args)
      end
    end
  end
end
