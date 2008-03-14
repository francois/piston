LIBS = %w(piston-svn piston-core piston)

def each_lib
  LIBS.each do |libname|
    Dir.chdir(libname) do
      yield libname
    end
  end
end

task :install_gem do
  each_lib { sh "rake install_gem" }
end

task :test do
  each_lib { sh "rake test" }
end

task :default => :test
