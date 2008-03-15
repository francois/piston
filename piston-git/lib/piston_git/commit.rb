require "piston_core/revision"

module PistonGit
  class Commit < PistonCore::Revision
    alias_method :commit, :revision

    def checkout_to(dir)
      git(:clone, repository.url, dir)
      Dir.chdir(dir) do
        git(:checkout, "-b", "my-#{revision}", revision)
        if revision == "HEAD" then
          response = git(:log, "-n", "1")
          @revision = $1 if response =~ /commit\s+([a-f\d]{40})/i
        end
      end

      def remember_values
        { PistonGit::URL => repository.url, PistonGit::COMMIT => commit }
      end
    end
  end
end
