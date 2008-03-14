LIBS = %w(piston-core piston-svn piston)

def each_lib
  LIBS.each do |libname|
    Dir.chdir(libname) do
      yield libname
    end
  end
end

def each_lib_reversed
  LIBS.reverse.each do |libname|
    Dir.chdir(libname) do
      yield libname
    end
  end
end

namespace :gem do
  task :install do
    each_lib { sh "rake install_gem" }
  end

  task :uninstall do
    each_lib_reversed {|libname| sh "sudo gem uninstall #{libname}"}
  end
end

task :test do
  each_lib { sh "rake test" }
end

task :default => :test
