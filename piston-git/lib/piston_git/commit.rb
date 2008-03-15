require "piston_git/client"
require "piston_core/revision"

module PistonGit
  class Commit < PistonCore::Revision
    extend PistonGit::Client
    def git(*args); self.class.git(*args); end

    alias_method :commit, :revision

    def checkout_to(dir)
      @dir = dir
      git(:clone, repository.url, @dir)
      Dir.chdir(@dir) do
        git(:checkout, "-b", "my-#{revision}", revision)
        if revision == "HEAD" then
          response = git(:log, "-n", "1")
          @revision = $1 if response =~ /commit\s+([a-f\d]{40})/i
        end
      end

      def remember_values
        { PistonGit::URL => repository.url, PistonGit::COMMIT => commit }
      end

      def each
        raise ArgumentError, "Never cloned + checked out" if @dir.nil?
        @dir.find do |path|
          Find.prune if path.to_s =~ %r{/[.]git}
          yield path.relative_path_from(@dir)
        end
      end
    end
  end
end
