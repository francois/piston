require "piston/git/commit"
require "uri"

module Piston
  module Git
    class Repository < Piston::Repository
      Piston::Repository.add_handler self

      class << self
        def understands_url?(url)
          uri = URI.parse(url) rescue nil
          return true if uri && %w(git).include?(uri.scheme)

          begin
            response = git("ls-remote", "--heads", url)
            return false if response.nil? || response.strip.chomp.empty?
            !!(response =~ /[a-f\d]{40}\s/)
          rescue Piston::Git::Client::CommandError
            false
          end
        end

        def client
          @@client ||= Piston::Git::Client.instance
        end

        def git(*args)
          client.git(*args)
        end
        
        def repository_type
          'git'
        end
      end

      def git(*args)
        self.class.git(*args)
      end

      def at(commit)
        case commit
        when Hash
          Piston::Git::Commit.new(self, commit[Piston::Git::COMMIT])
        when :head
          Piston::Git::Commit.new(self, "HEAD")
        else
          Piston::Git::Commit.new(self, commit)
        end
      end

      def basename
        self.url.split("/").last.sub(".git", "")
      end
    end
  end
end
