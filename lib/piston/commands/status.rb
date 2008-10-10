require "piston/commands/base"

module Piston
  module Commands
    class Status < Piston::Commands::Base
      def run(wcdir)
        # Get the working copy handler to search pistonized folders inside it
        handler = guess_wc(wcdir).class
        
        # First, find the list of pistonized folders
        repos = Hash.new
        Pathname.glob(wcdir + '**/.piston.yml') do |path|
          repos[path.dirname] = Hash.new
        end

        # Then, get their properties
        repos.each_pair do |path, props|
          logger.debug {"Get info of #{path}"}
          working_copy = handler.new(path)
          working_copy.validate!
          props.update(working_copy.info)
          props[:locally_modified] = 'M' if working_copy.locally_modified
          props[:remotely_modified] = 'M' if show_updates and working_copy.remotely_modified
        end

        # Display the results
        repos.each_pair do |path, props|
          printf "%1s%1s %6s %s (%s)\n", props[:locally_modified],
              props[:remotely_modified], props["lock"] ? 'locked' : '', path, props["repository_url"]
        end

        puts "No pistonized folders found in #{wcdir}" if repos.empty?
      end

      def show_updates
        options[:show_updates]
      end
    end
  end
end
