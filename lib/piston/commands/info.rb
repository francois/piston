require "piston/commands/base"

module Piston
  module Commands
    class Info < Piston::Commands::Base
      attr_reader :options

      def run(wcdir)
        working_copy = guess_wc(wcdir)
        raise Piston::WorkingCopy::NotWorkingCopy if !working_copy.exist? || !working_copy.pistonized?
        working_copy.info.to_yaml
      end
    end
  end
end
