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

      def checkout_to(path)
        @wcpath = path.kind_of?(Pathname) ? path : Pathname.new(path)
        answer = svn(:checkout, "--revision", revision, repository.url, path)
        if answer =~ /Checked out revision (\d+)[.]/ then
          if revision == "HEAD" then
            @revision = $1.to_i
          elsif revision != $1.to_i then
            raise Failed, "Did not get the revision I wanted to checkout.  Subversion checked out #{$1}, I wanted #{revision}"
          end
        else
          raise Failed, "Could not checkout revision #{revision} from #{repository.url} to #{path}\n#{answer}"
        end
      end

      def remember_values
        str = svn(:info, "--revision", revision, repository.url)
        raise Failed, "Could not get 'svn info' from #{repository.url} at revision #{revision}" if str.nil? || str.chomp.strip.empty?
        info = YAML.load(str)
        { Piston::Svn::UUID => info["Repository UUID"],
          Piston::Svn::REMOTE_REV => info["Revision"]}
      end

      def each
        raise ArgumentError, "Revision #{revision} of #{repository.url} was never checked out -- can't iterate over files" unless @wcpath

        svn(:ls, "--recursive", @wcpath).each do |relpath|
          next if relpath =~ %r{/$}
          yield relpath.chomp
        end
      end

      def copy_to(relpath, abspath)
        raise ArgumentError, "Revision #{revision} of #{repository.url} was never checked out -- can't iterate over files" unless @wcpath

        Pathname.new(abspath).dirname.mkpath
        FileUtils.cp(@wcpath + relpath, abspath)
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
    end
  end
end
