require "piston/commands/base"

module Piston
  module Commands
    class Info < Piston::Commands::Base
      attr_reader :options

      def run(wcdir)
        working_copy = working_copy!(wcdir)
        working_copy.info.to_yaml
      end
    end
  end
end
