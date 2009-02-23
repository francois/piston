require "piston/commands/base"

module Piston
  module Commands
    class Diff < Piston::Commands::Base
      def run
        working_copy = working_copy!(options[:wcdir])
        working_copy.diff
      end
    end
  end
end
