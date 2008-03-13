require "piston/commands/base"

module Piston
  module Commands
    class Import < Piston::Commands::Base
      attr_reader :options

      def temp_dir_name(working_copy)
        working_copy.path.parent + ".#{working_copy.path.basename}.tmp"
      end

      def create_tmpdir(tmpdir)
        tmpdir_create_attempted = false
        begin
          debug {"Creating temporary directory: #{tmpdir}"}
          tmpdir.mkdir
        rescue Errno::EEXIST
          if tmpdir_create_attempted then
            raise
          else
            tmpdir.rmtree
            tmpdir_create_attempted = true
            retry
          end
        end
      end

      def run(revision, working_copy)
        tmpdir = temp_dir_name(working_copy)

        abort("Path #{working_copy} already exists and --force not given.  Aborting...") if working_copy.exist? && !force

        begin
          create_tmpdir(tmpdir)
          revision.checkout_to(tmpdir)
          working_copy.create
          working_copy.copy_from(tmpdir)
          working_copy.remember(revision.remember_values)
          working_copy.finalize
        ensure
          debug {"Removing temporary directory: #{tmpdir}"}
          tmpdir.rmtree
        end
      end
    end
  end
end
