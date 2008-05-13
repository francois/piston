require "piston/commands/base"

module Piston
  module Commands
    class LockUnlock < Piston::Commands::Base
      attr_reader :options

      def run(wcdir, lock)
        working_copy = working_copy!(wcdir)

        values = working_copy.recall
        values["lock"] = lock
        working_copy.remember(values, values["handler"])
        working_copy.finalize

        text = lock ? "Locked" : "Unlocked"
        logger.info "#{text} #{working_copy} against automatic updates"
      end
    end
  end
end
