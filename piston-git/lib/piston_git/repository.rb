require "piston_git/commit"

module PistonGit
  class Repository < PistonCore::Repository
    def at(commit)
      PistonGit::Commit.new(self, commit)
    end
  end
end
