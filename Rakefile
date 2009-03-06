Dir["tasks/**/*.rake"].each { |rake| load rake }

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name              = "piston"
    s.summary           = "Ease your vendor branch management worries"
    s.email             = "francois@teksol.info"
    s.homepage          = "http://francois.github.com/piston"
    s.description       = "Piston makes it easy to merge vendor branches into your own repository, without worrying about which revisions were grabbed or not.  Piston will also keep your local changes in addition to the remote changes."
    s.authors           = "Francois Beausoleil"
    s.has_rdoc          = false
    s.rubyforge_project = "piston"

    s.add_development_dependency "cucumber", ">= 0.1.16"

    s.add_runtime_dependency "main", ">= 2.8.3"
    s.add_runtime_dependency "log4r", ">= 1.0.5"
    s.add_runtime_dependency "activesupport", ">= 2.0.0"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
