require "piston/commands/base"

module Piston
  module Commands
    class Update < Piston::Commands::Base
      # +wcdir+ is the working copy we're going to change.
      # +to+ is the new target revision we want to be at after update returns.
      def run(wcdir, to)
        working_copy = Piston::WorkingCopy.guess(wcdir)

        logger.debug {"Recalling previously saved values"}
        values = working_copy.recall

        repository_class = values["repository_class"]
        repository_url = values["repository_url"]
        repository = repository_class.constantize.new(repository_url)
        from_revision = repository.at(values["handler"])
        to_revision = repository.at(to)

        logger.debug {"Validating that #{from_revision} exists and is capable of performing the update"}
        from_revision.validate!

        logger.info {"Updating from #{from_revision} to #{to_revision}"}
        working_copy.apply_differences(from_revision.differences_with(to_revision))
      end
    end
  end
end
