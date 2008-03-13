require "piston/revision"

module Piston
  module Svn
    class Revision < Piston::Revision
      include Piston::Svn::Client

      def checkout_to(path)
        svn :checkout, "--quiet", "--revision", revision, path
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
