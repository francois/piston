require "piston/core/version"

module Piston
  module Core
    class << self
      def version_message
        "Piston %s\nCopyright 2006-2008, François Beausoleil <francois@teksol.info>\nhttp://piston.rubyforge.org/\nDistributed under an MIT-like license." % Piston::Core::VERSION::STRING
      end
    end
  end
end
