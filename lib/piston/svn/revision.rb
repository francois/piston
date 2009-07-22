require "piston/revision"
require "fileutils"

module Piston
  module Svn
    class Revision < Piston::Revision
      class InvalidRevision < RuntimeError; end
      class RepositoryMoved < InvalidRevision; end
      class UuidChanged < InvalidRevision; end

      def client
        @client ||= Piston::Svn::Client.instance
      end

      def svn(*args)
        client.svn(*args)
      end

      def name
        "r#{revision}"
      end

      def checkout_to(dir)
        super
        answer = svn(:checkout, "--revision", revision, repository.url, dir)
        if answer =~ /Checked out revision (\d+)[.]/ then
          if revision == "HEAD" then
            @revision = $1.to_i
          elsif revision.to_i != $1.to_i then
            raise InvalidRevision, "Did not get the revision I wanted to checkout.  Subversion checked out #{$1}, I wanted #{revision}"
          end
        else
          raise InvalidRevision, "Could not checkout revision #{revision} from #{repository.url} to #{dir}\n#{answer}"
        end
      end

      def update_to(revision)
        raise ArgumentError, "Revision #{self.revision} of #{repository.url} was never checked out -- can't update" unless @dir
        
        answer = svn(:update, "--revision", revision, @dir)
        if answer =~ /(Updated to|At) revision (\d+)[.]/ then
          if revision == "HEAD" then
            @revision = $2.to_i
          elsif revision != $2.to_i then
            raise InvalidRevision, "Did not get the revision I wanted to update.  Subversion update to #{$1}, I wanted #{revision}"
          end
        else
          raise InvalidRevision, "Could not update #{@dir} to revision #{revision} from #{repository.url}\n#{answer}"
        end
        added = relative_paths(answer.scan(/^A\s+(.*)$/).flatten)
        deleted = relative_paths(answer.scan(/^D\s+(.*)$/).flatten)
        renamed = []
        [added, deleted, renamed]
      end

      def remember_values
        str = svn(:info, "--revision", revision, repository.url)
        raise Failed, "Could not get 'svn info' from #{repository.url} at revision #{revision}" if str.nil? || str.chomp.strip.empty?
        info = YAML.load(str)
        { Piston::Svn::UUID => info["Repository UUID"],
          Piston::Svn::REMOTE_REV => info["Revision"]}
      end

      def each
        raise ArgumentError, "Revision #{revision} of #{repository.url} was never checked out -- can't iterate over files" unless @dir

        svn(:ls, "--recursive", @dir).split("\n").each do |relpath|
          next if relpath =~ %r{/$}
          next if relpath == '.piston.yml'
          yield relpath.chomp
        end
      end

      def validate!
        data = svn(:info, "--revision", revision, repository.url)
        info = YAML.load(data)
        actual_uuid = info["Repository UUID"]
        raise RepositoryMoved, "Repository at #{repository.url} does not exist anymore:\n#{data}" if actual_uuid.blank?
        raise UuidChanged, "Expected repository at #{repository.url} to have UUID #{recalled_uuid} but found #{actual_uuid}" if recalled_uuid != actual_uuid
      end

      def recalled_uuid
        recalled_values[Piston::Svn::UUID]
      end

      def remotely_modified
        logger.debug {"Get last revision in #{repository.url}"}
        data = svn(:info, repository.url)
        info = YAML.load(data)
        latest_revision = info["Last Changed Rev"].to_i
        revision < latest_revision
      end

      def exclude_for_diff
        Piston::Svn::EXCLUDE
      end

      def resolve!
        logger.debug {"Resolving #{@revision} to it's real value"}
        return if @revision.to_i == @revision && !@revision.blank?
        data = YAML.load(svn(:info, repository.url))
        @revision = data["Last Changed Rev"].to_i
        logger.debug {"Resolved #{@revision}"}
        @revision
      end

      private
      def relative_paths(paths)
        paths.map { |item| Pathname.new(item).relative_path_from(@dir) }
      end
    end
  end
end
