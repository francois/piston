require "piston_git/commit"
require "uri"

module PistonGit
  class Repository < PistonCore::Repository
    extend PistonGit::Client
    def git(*args); self.class.git(*args); end

    PistonCore::Repository.add_handler self

    class << self
      def understands_url?(url)
        uri = URI.parse(url)
        return true if %w(git).include?(uri.scheme)

        response = git("ls-remote", "--heads", url)
        return false if response.nil? || response.strip.chomp.empty?
        !!(response =~ /[a-f\d]{40}\s/)
      end
    end

    def at(commit)
      PistonGit::Commit.new(self, commit)
    end
  end
end
