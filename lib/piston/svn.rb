require "piston/svn/client"
require "piston/svn/repository"
require "piston/svn/revision"
require "piston/svn/working_copy"

module Piston
  module Svn
    ROOT        = "piston:root"
    UUID        = "piston:uuid"
    REMOTE_REV  = "piston:remote-revision"
    LOCAL_REV   = "piston:local-revision"
    LOCKED      = "piston:locked"
  end
end
