require "piston/git/client"
require "piston/revision"
require "fileutils"

module Piston
  module Git
    class Commit < Piston::Revision
      alias_method :commit, :revision

      def client
        @client ||= Piston::Git::Client.instance
      end

      def git(*args)
        client.git(*args)
      end

      def name
        commit[0,7]
      end

      def checkout_to(dir)
        @dir = dir
        git(:clone, repository.url, @dir)
        Dir.chdir(@dir) do
          logger.debug {"in dir #{@dir}"}
          git(:checkout, "-b", "my-#{revision}", revision)
          if revision == "HEAD" then
            response = git(:log, "-n", "1")
            @revision = $1 if response =~ /commit\s+([a-f\d]{40})/i
          end
        end

        def remember_values
          { Piston::Git::URL => repository.url, Piston::Git::COMMIT => commit }
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

        def copy_to(relpath, abspath)
          Pathname.new(abspath).dirname.mkpath rescue nil
          FileUtils.cp(@dir + relpath, abspath)
        end
      end
    end
  end
end
