require "pathname"
require "logger"

@root = Pathname.new(File.dirname(__FILE__)).parent

$:.unshift @root + "lib"
$:.unshift @root + "../piston-core/lib"

require "piston_core"
require "piston_core/repository"
require "piston_core/working_copy"
require "piston_svn"
require "piston_svn/client"
require "piston_svn/repository"
require "piston_svn/working_copy"
require "piston_svn/revision"

PISTON_DEFAULT_LOGGER = Logger.new(STDOUT)
PistonCore::Repository.logger = PistonCore::WorkingCopy.logger = PISTON_DEFAULT_LOGGER
def logger; PISTON_DEFAULT_LOGGER; end
include PistonSvn::Client

(@root + "tmp/repos").rmtree rescue nil
(@root + "tmp/wc").rmtree rescue nil
(@root + "tmp/.xlsuite.tmp").rmtree rescue nil

svnadmin :create, @root + "tmp/repos"
svn :checkout, "file://#{(@root + 'tmp/repos').realpath}", @root + "tmp/wc"

repos = PistonSvn::Repository.new("http://svn.xlsuite.org/trunk/lib")
rev = repos.at(:head)
rev.checkout_to(@root + "tmp/.xlsuite.tmp")
wc = PistonSvn::WorkingCopy.new(@root + "tmp/wc/vendor")
wc.create
wc.copy_from(rev)
wc.remember(rev.remember_values)
wc.finalize
