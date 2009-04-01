require "subclass_responsibility_error"

require "piston/repository"
require "piston/revision"
require "piston/working_copy"

require "piston/git"
require "piston/svn"
require "piston/commands"

require "pathname"

module Piston
  class << self
    def version_message
      "Piston %s\nCopyright 2006-2008, Francois Beausoleil <francois@teksol.info>\nhttp://piston.rubyforge.org/\nDistributed under an MIT-like license." % Piston::VERSION::STRING
    end
  end
end
