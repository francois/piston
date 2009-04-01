require "piston/commands/base"

module Piston
  module Commands
    class Convert < Piston::Commands::Base
      attr_reader :options

      def run(targets)
        targets = Array.new unless targets
        wc = Piston::Svn::WorkingCopy.new(Dir.pwd)
        importer = Piston::Commands::Import.new(options)
        returning(Array.new) do |conversions|
          wc.externals.each_pair do |dir, args|
            next unless targets.empty? || targets.detect {|target| dir.to_s.include?(target.to_s) }
            conversions << dir

            logger.info "Importing #{dir.relative_path_from(wc.path)} from #{args[:url]}"
            importer.run(args[:url], args[:revision], dir)
          end

          wc.remove_external_references(*targets)
        end
      end

			def start(*args)
				targets = args.flatten.map {|d| Pathname.new(d).expand_path}
				run(targets)
				puts "#{targets.length} directories converted"
			end
		end
	end
end
