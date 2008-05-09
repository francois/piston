require "piston/commands/base"

module Piston
  module Commands
    class LockUnlock < Piston::Commands::Base
      attr_reader :options

      def run(wcdir, lock)
        working_copy = Piston::WorkingCopy.guess(wcdir)
        raise Piston::WorkingCopy::NotWorkingCopy if !working_copy.exist? || !working_copy.pistonized?

        values = working_copy.recall
        values["lock"] = lock
        working_copy.remember(values, values["handler"])
        working_copy.finalize

        logger.info "Locked #{working_copy} against automatic updates"
      end
    end
  end
end
