require "piston/working_copy"
require "piston/git/client"

module Piston
  module Git
    class WorkingCopy < Piston::WorkingCopy
      extend Piston::Git::Client
      def git(*args); self.class.git(*args); end

      # Register ourselves as a handler for working copies
      Piston::WorkingCopy.add_handler self

      class << self
        def understands_dir?(dir)
          begin
            response = git(:log, "-n", "1", dir)
            !!(response =! /commit\s+[a-f\d]{40}/)
          rescue BadCommand
            false
          end
        end
      end

      def create
        path.mkdir rescue nil
      end

      def exist?
        path.directory?
      end

      def finalize
        git(:add, path)
      end

      def copy_from(revision)
        revision.each do |relpath|
          target = path + relpath
          target.dirname.mkdir rescue nil

          logger.debug {"Copying #{relpath} to #{target}"}
          revision.copy_to(relpath, target)
        end
      end
    end
  end
end
