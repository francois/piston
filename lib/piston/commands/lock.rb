require "piston/commands/base"

module Piston
  module Commands
    class Lock < Piston::Commands::Base
      attr_reader :options
      def run(lock)
        working_copy = Piston::WorkingCopy.guess(options[:wcdir])
        raise Piston::WorkingCopy::NotWorkingCopy if !working_copy.exist? || !working_copy.pistonized?
        values = working_copy.recall
        values["lock"] = lock
        working_copy.remember(values, values["handler"])
        working_copy.finalize
      end
    end
  end
end
