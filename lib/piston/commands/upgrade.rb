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
    end
  end
end
