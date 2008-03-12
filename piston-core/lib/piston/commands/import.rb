require "piston/commands/base"

module Piston
  module Commands
    class Import < Piston::Commands::Base
      attr_reader :options

      def initialize(options={})
        @options = options
        logger.debug {"Import with options: #{options.inspect}"}
      end

      def run(revision, working_copy)
        tmpdir = working_copy.path.parent + ".#{working_copy.path.basename}.tmp"

        begin
          debug {"Creating temporary directory: #{tmpdir}"}
          tmpdir.mkdir
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
