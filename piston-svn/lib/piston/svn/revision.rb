require "piston/revision"

module Piston
  module Svn
    class Revision < Piston::Revision
      include Piston::Svn::Client

      def checkout_to(path)
        svn :checkout, "--quiet", "--revision", revision, path
      end
    end
  end
end
