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
          git(:checkout, "-b", branch_name, commit)
          response = git(:log, "-n", "1")
          @sha1 = $1 if response =~ /commit\s+([a-f\d]{40})/i
        end
      end

      def update_to(commit)
        raise ArgumentError, "Commit #{self.commit} of #{repository.url} was never checked out -- can't update" unless @dir
        
        Dir.chdir(@dir) do
          logger.debug {"Saving old changes before updating"}
          git(:commit, '-a', '-m', 'old changes')
          logger.debug {"Merging old changes with #{commit}"}
          git(:merge, '--squash', commit)
          output = git(:status)
          added = output.scan(/new file:\s+(.*)$/).flatten
          deleted = output.scan(/deleted:\s+(.*)$/).flatten
          renamed = output.scan(/renamed:\s+(.+) -> (.+)$/)
          [added, deleted, renamed]
        end
      end

      def remember_values
        # find last commit for +commit+ if it wasn't checked out
        @sha1 = git('ls-remote', repository.url, commit).match(/\w+/)[0] unless @sha1
        # if ls-remote returns nothing, +commit+ must be a commit, not a branch
        @sha1 = commit unless @sha1
        { Piston::Git::COMMIT => @sha1, Piston::Git::BRANCH => commit }
      end

      def each
        raise ArgumentError, "Never cloned + checked out" if @dir.nil?
        @dir.find do |path|
          Find.prune if path.to_s =~ %r{/[.]git}
          next if @dir == path
          next if File.directory?(path)
          next if @dir + '.piston.yml' == path
          yield path.relative_path_from(@dir)
        end
      end

      def remotely_modified
        branch = recalled_values[Piston::Git::BRANCH]
        logger.debug {"Get last commit in #{branch} of #{repository.url}"}
        commit = git('ls-remote', repository.url, branch).match(/\w+/)
        # when we update to a commit, instead latest commit of a branch, +branch+ will be a commit, and ls-remote can return nil
        commit = commit[0] unless commit.nil?
        commit != self.commit
      end

      def exclude_for_diff
        Piston::Git::EXCLUDE
      end

      def to_s
        "commit #{sha1}"
      end

      def resolve!
        # NOP, because @sha1 is what we want
      end
    end
  end
end
