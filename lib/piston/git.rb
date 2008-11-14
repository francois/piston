require "piston/git/client"
require "piston/git/repository"
require "piston/git/commit"
require "piston/git/working_copy"

module Piston
  module Git
    URL = "url"
    COMMIT = "commit"
    BRANCH = "branch"
    EXCLUDE = [".git"]
  end
end
