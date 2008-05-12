require "piston/commands/base"

module Piston
  module Commands
    class Info < Piston::Commands::Base
      attr_reader :options

      def run(wcdir)
        working_copy = Piston::WorkingCopy.guess(wcdir)
        raise Piston::WorkingCopy::NotWorkingCopy if !working_copy.exist? || !working_copy.pistonized?
        puts working_copy.info
      end
    end
  end
end
