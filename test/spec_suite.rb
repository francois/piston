dir = File.dirname(__FILE__)
Dir["#{dir}/**/test_*.rb"].each do |file|
  require file
end