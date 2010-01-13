require "piston/commands/base"

module Piston
  module Commands
    class Status < Piston::Commands::Base
      def run(wcdir)
        # Get the working copy handler to search pistonized folders inside it
        handler = guess_wc(wcdir).class
        props   = Hash.new

        # Then, get that repository's properties
        logger.debug {"Get info of #{wcdir}"}
        working_copy = handler.new(wcdir)
        working_copy.validate!
        props.update(working_copy.info)
        props[:locally_modified]  = 'M' if working_copy.locally_modified
        props[:remotely_modified] = 'M' if show_updates && working_copy.remotely_modified

        # Display the results
        printf "%1s%1s %6s %s (%s)\n", props[:locally_modified],
          props[:remotely_modified], props["lock"] ? 'locked' : '', wcdir.to_s, props["repository_url"]
      end

      def show_updates
        options[:show_updates]
      end

			def start(*args)
        paths = args.flatten.map {|d| Pathname.new(d).expand_path}
        paths = find_local_piston_folders if paths.empty?
        paths.each do |wcdir|
					begin
						run(wcdir)
					rescue Piston::WorkingCopy::NotWorkingCopy
						puts "#{wcdir} is not a working copy"
					end
				end
			end

      private

      def find_local_piston_folders
        Pathname.glob(Pathname.new(Dir.pwd) + '**/.piston.yml').map {|path| path + ".."}.map(&:expand_path)
      end
    end
  end
end
