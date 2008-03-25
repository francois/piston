require "piston/commands/base"

module Piston
  module Commands
    class Import < Piston::Commands::Base
      attr_reader :options

      def temp_dir_name(working_copy)
        working_copy.path.parent + ".#{working_copy.path.basename}.tmp"
      end

      def run(repository_url, target_revision, wcdir)
        repository = Piston::Repository.guess(repository_url)
        revision = repository.at(target_revision)

        wcdir = wcdir.nil? ? repository.basename : wcdir
        debug {"repository_url: #{repository_url.inspect}, target_revision: #{target_revision.inspect}, wcdir: #{wcdir.inspect}"}
        working_copy = Piston::WorkingCopy.guess(wcdir)

        tmpdir = temp_dir_name(working_copy)

        abort("Path #{working_copy} already exists and --force not given.  Aborting...") if working_copy.exist? && !force

        begin
          revision.checkout_to(tmpdir)
          working_copy.create
          working_copy.copy_from(revision)
          working_copy.remember({:lock => options[:lock]}, revision.remember_values)
          working_copy.finalize
        ensure
          debug {"Removing temporary directory: #{tmpdir}"}
          tmpdir.rmtree rescue nil
        end
      end
    end
  end
end
