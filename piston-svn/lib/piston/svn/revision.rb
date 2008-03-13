require "piston/revision"

module Piston
  module Svn
    class Revision < Piston::Revision
      include Piston::Svn::Client

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
          raise Failed, "Could not checkout revision #{revision} from #{repository.url}\n#{answer}"
        end
      end

      def remember_values
        str = svn(:info, "--revision", revision, repository.url)
        raise Piston::Svn::Client::Failed, "Could not get 'svn info' from #{repository.url} at revision #{revision}" if str.nil? || str.chomp.strip.empty?
        info = YAML.load(str)
        { Piston::Svn::UUID => info["Repository UUID"],
          Piston::Svn::ROOT => info["URL"],
          Piston::Svn::REMOTE_REV => info["Revision"]}
      end
    end
  end
end
