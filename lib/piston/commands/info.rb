require "piston/commands/base"

module Piston
  module Commands
    class Info < Piston::Commands::Base
      attr_reader :options

      def run(wcdir)
        working_copy = working_copy!(wcdir)
        working_copy.info.to_yaml
      end

			def start(*args)
				args.flatten.map {|d| Pathname.new(d).expand_path}.each do |wcdir|
					begin
						run(wcdir)
					rescue Piston::WorkingCopy::NotWorkingCopy
						puts "#{wcdir} is not a working copy"
					end
				end
			end
    end
  end
end
