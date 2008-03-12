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
        puts "Importing #{revision} into #{working_copy}"
      end
    end
  end
end
