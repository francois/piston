require "piston/commands/base"

module Piston
  module Commands
    class Update < Piston::Commands::Base
      # +wcdir+ is the working copy we're going to change.
      # +to+ is the new target revision we want to be at after update returns.
      def run(wcdir, to)
        working_copy = working_copy!(wcdir)

        logger.debug {"Recalling previously saved values"}
        values = working_copy.recall
        return "#{wcdir} is locked: not updating" if values["lock"]

        repository    = working_copy.repository
        from_revision = repository.at(values["handler"])
        to_revision   = repository.at(to)
        to_revision.resolve!

        logger.debug {"Validating that #{from_revision} exists and is capable of performing the update"}
        from_revision.validate!

        logger.info {"Updating from #{from_revision} to #{to_revision}"}

        changed = working_copy.update(from_revision, to_revision, options[:lock])
        if changed then
          logger.info {"Updated #{wcdir} to #{to_revision}"}
        else
          logger.info {"Upstream #{repository} was unchanged from #{from_revision}"}
        end
      end
    end
  end
end
