dir = File.dirname(__FILE__)
Dir["#{dir}/commands/**/*.rb"].each do |f|
  require f.gsub("#{File.expand_path("#{File.dirname(f)}/../..")}/", "")
end
