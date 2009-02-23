Dir["tasks/**/*.rake"].each { |rake| load rake }

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "piston"
    s.summary = "Easy your vendor branch management worries"
    s.email = "josh@technicalpickles.com"
    s.homepage = "http://github.com/francois/piston"
    s.description = "Piston makes it easy to merge vendor branches into your own repository, without worrying about which revisions were grabbed or not.  Piston will also keep your local changes in addition to the remote changes."
    s.authors = ["François Beausoleil"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
