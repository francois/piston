require "piston/commands/base"

module Piston
  module Commands
    class LockUnlock < Piston::Commands::Base
      attr_reader :options

      def run(wcdir, lock)
        working_copy = guess_wc(wcdir)
        working_copy.validate!

        values = working_copy.recall
        values["lock"] = lock
        working_copy.remember(values, values["handler"])
        working_copy.finalize

        logger.info "Locked #{working_copy} against automatic updates"
      end
    end
  end
end
