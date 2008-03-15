require "pathname"
require "logger"

@root = Pathname.new(File.dirname(__FILE__)).parent

$:.unshift @root + "lib"
$:.unshift @root + "../piston-core/lib"

require "piston"
require "piston/svn"

PISTON_DEFAULT_LOGGER = Logger.new(STDOUT)
Piston::Repository.logger = Piston::WorkingCopy.logger = PISTON_DEFAULT_LOGGER
def logger; PISTON_DEFAULT_LOGGER; end
include Piston::Svn::Client

(@root + "tmp/repos").rmtree rescue nil
(@root + "tmp/wc").rmtree rescue nil
(@root + "tmp/.xlsuite.tmp").rmtree rescue nil

svnadmin :create, @root + "tmp/repos"
svn :checkout, "file://#{(@root + 'tmp/repos').realpath}", @root + "tmp/wc"

repos = Piston::Svn::Repository.new("http://svn.xlsuite.org/trunk/lib")
rev = repos.at(:head)
rev.checkout_to(@root + "tmp/.xlsuite.tmp")
wc = Piston::Svn::WorkingCopy.new(@root + "tmp/wc/vendor")
wc.create
wc.copy_from(rev)
wc.remember(rev.remember_values)
wc.finalize
