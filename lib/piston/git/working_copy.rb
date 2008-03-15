require "piston/working_copy"
require "piston/git/client"

module Piston
  module Git
    class WorkingCopy < Piston::WorkingCopy
      extend Piston::Git::Client
      def git(*args); self.class.git(*args); end

      def create
        path.mkdir rescue nil
      end

      def exist?
        path.directory?
      end

      def finalize
        git(:add, path)
      end
    end
  end
end
