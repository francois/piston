require "piston_core/working_copy"
require "piston_git/client"

module PistonGit
  class WorkingCopy < PistonCore::WorkingCopy
    extend PistonGit::Client
    def git(*args); self.class.git(*args); end
  end
end
