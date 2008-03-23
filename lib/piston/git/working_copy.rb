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
          path = dir
          begin
            begin
              logger.debug {"git status on #{path}"}
              Dir.chdir(path) do
                response = git(:status)
                return true if response =~ /# On branch /
              end
            rescue Errno::ENOENT
              # NOP, we assume this is simply because the folder hasn't been created yet
              path = path.parent
              retry unless path.to_s == "/"
              return false
            end
          rescue BadCommand
            # NOP, as we return false below
          rescue Piston::Git::Client::CommandError
            # This is certainly not a Git repository
            false
          end

          false
        end
      end

      def create
        path.mkpath rescue nil
      end

      def exist?
        path.directory?
      end

      def finalize
        Dir.chdir(path) { git(:add, ".") }
      end
    end
  end
end
