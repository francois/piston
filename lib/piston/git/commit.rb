require "piston/git/client"
require "piston/revision"
require "fileutils"

module Piston
  module Git
    class Commit < Piston::Revision
      class InvalidCommit < RuntimeError; end
      class Gone < InvalidCommit; end

      alias_method :commit, :revision
      attr_reader :sha1

      def initialize(repository, revision, recalled_values={})
        super
        @revision = 'master' if @revision.upcase == 'HEAD'
      end

      def client
        @client ||= Piston::Git::Client.instance
      end

      def git(*args)
        client.git(*args)
      end

      def recalled_commit_id
        recalled_values[Piston::Git::COMMIT]
      end

      def validate!
        begin
          data = git("ls-remote", @repository.url)
          self
        rescue Piston::Git::Client::CommandError
          raise Piston::Git::Commit::Gone, "Repository at #{@repository.url} does not exist anymore"
        end
      end

      def name
        commit[0,7]
      end

      def branch_name
        "my-#{commit}"
      end

      def checkout_to(dir)
        super
        git(:clone, repository.url, @dir)
        Dir.chdir(@dir) do
          logger.debug {"in dir #{@dir}"}
          git(:checkout, "-b", branch_name, commit)
          response = git(:log, "-n", "1")
          @sha1 = $1 if response =~ /commit\s+([a-f\d]{40})/i
        end
      end

      def update_to(commit)
        raise ArgumentError, "Commit #{self.commit} of #{repository.url} was never checked out -- can't update" unless @dir
        
        Dir.chdir(@dir) do
          logger.debug {"in dir #{@dir}"}
          git(:commit, '-a', '-m', 'local changes') unless git(:status) =~ /nothing to commit/
          git(:merge, commit)
        end
      end

      def remember_values
        { Piston::Git::COMMIT => @sha1, Piston::Git::BRANCH => commit }
      end

      def each
        raise ArgumentError, "Never cloned + checked out" if @dir.nil?
        @dir.find do |path|
          Find.prune if path.to_s =~ %r{/[.]git}
          next if @dir == path
          next if File.directory?(path)
          yield path.relative_path_from(@dir)
        end
      end
    end
  end
end
