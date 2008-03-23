require "piston/git/commit"
require "uri"

module Piston
  module Git
    class Repository < Piston::Repository
      extend Piston::Git::Client
      def git(*args); self.class.git(*args); end

      Piston::Repository.add_handler self

      class << self
        def understands_url?(url)
          uri = URI.parse(url)
          return true if %w(git).include?(uri.scheme)

          begin
            response = git("ls-remote", "--heads", url)
            return false if response.nil? || response.strip.chomp.empty?
            !!(response =~ /[a-f\d]{40}\s/)
          rescue Piston::Git::Client::CommandError
            false
          end
        end
      end

      def at(commit)
        case commit
        when :head
          Piston::Git::Commit.new(self, "HEAD")
        else
          Piston::Git::Commit.new(self, commit)
        end
      end
    end
  end
end
