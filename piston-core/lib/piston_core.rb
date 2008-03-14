require "piston_core/version"
require "piston_core/repository"
require "piston_core/revision"
require "piston_core/working_copy"

module PistonCore
  class << self
    def version_message
        "Piston %s\nCopyright 2006-2008, François Beausoleil <francois@teksol.info>\nhttp://piston.rubyforge.org/\nDistributed under an MIT-like license." % PistonCore::VERSION::STRING
    end
  end
end
