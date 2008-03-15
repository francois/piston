require "piston_svn/client"
require "piston_svn/repository"
require "piston_svn/revision"
require "piston_svn/working_copy"

module PistonSvn
  ROOT        = "piston:root"
  UUID        = "piston:uuid"
  REMOTE_REV  = "piston:remote-revision"
  LOCAL_REV   = "piston:local-revision"
  LOCKED      = "piston:locked"
end
