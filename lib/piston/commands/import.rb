require "piston/commands/base"

module Piston
  module Commands
    class Import < Piston::Commands::Base
      attr_reader :options

      def temp_dir_name(working_copy)
        working_copy.path.parent + ".#{working_copy.path.basename}.tmp"
      end

      def run(revision, working_copy)
        tmpdir = temp_dir_name(working_copy)

        abort("Path #{working_copy} already exists and --force not given.  Aborting...") if working_copy.exist? && !force

        begin
          revision.checkout_to(tmpdir)
          working_copy.create
          working_copy.copy_from(revision)
          working_copy.remember({:lock => options[:lock]}, revision.remember_values)
          working_copy.finalize
        ensure
          debug {"Removing temporary directory: #{tmpdir}"}
          tmpdir.rmtree rescue nil
        end
      end
    end
  end
end
