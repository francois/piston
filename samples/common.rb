# Common code between all sample files.
# Setup the environment.
require "pathname"
require "logger"

@root = Pathname.new(File.dirname(__FILE__)).parent
$:.unshift("#{@root}lib"

require "piston"
require "piston/svn"
require "piston/git"

PISTON_DEFAULT_LOGGER = Logger.new(STDOUT)
Piston::Repository.logger = Piston::WorkingCopy.logger = PISTON_DEFAULT_LOGGER
def logger; PISTON_DEFAULT_LOGGER; end

include Piston::Svn::Client
include Piston::Git::Client

