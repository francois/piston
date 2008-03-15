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
            while path.parent
              response = git(:status, path)
              return true if response =~ /# On branch /
              path = path.parent
            end
          rescue BadCommand
            # NOP, as we return false below
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

      def remember(values)
        File.open(path + ".piston.yml", "wb") do |f|
          f.write({"format" => 1, "handler" => values}.to_yaml)
        end
      end
    end
  end
end
