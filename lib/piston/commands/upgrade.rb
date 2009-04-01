require "piston/commands/base"

module Piston
  module Commands
    class Upgrade < Piston::Commands::Base
      def run(*directories)
        # piston 1.x managed only subversion repositories
        directories = directories.select { |dir| Piston::Svn::WorkingCopy.understands_dir? dir }

        repositories = Piston::Svn::WorkingCopy.old_repositories(*directories)
        repositories.each do |repository|
          logger.debug {"Upgrading repository #{repository}"}
          Piston::Svn::WorkingCopy.new(repository).upgrade
        end

        repositories
      end

			def start(*args)
				targets = args.flatten.map {|d| Pathname.new(d).expand_path}
				run(targets)
				puts "#{targets.length} directories upgraded"
			end
    end
  end
end
