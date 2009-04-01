require "piston/commands/base"

module Piston
  module Commands
    class Diff < Piston::Commands::Base
      def run
        working_copy = working_copy!(options[:wcdir])
        working_copy.diff
      end

			def start(*args)
				args.flatten.map {|d| Pathname.new(d).expand_path}.each do |wcdir|
					begin
						options[:wcdir] = wcdir
						run
					rescue Piston::WorkingCopy::NotWorkingCopy
						puts "#{wcdir} is not a working copy"
					end
				end
			end
    end
  end
end
