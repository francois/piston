task :samples do
  Dir["samples/*"].each do |sample|
    next if sample =~ /common/
    ruby sample
  end
end
