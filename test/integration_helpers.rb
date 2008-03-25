PISTON_ROOT = Pathname.new(File.dirname(__FILE__)).parent.realpath

def logger
  @logger ||= Log4r::Logger["test"]
end

def runcmd(cmd, *args)
  cmdline = [cmd]
  cmdline += args
  cmdline = cmdline.flatten.map {|s| s.to_s}.join(" ")
  logger.debug "> #{cmdline}"

  output = `#{cmdline}`
  logger.debug "< #{output}"
  return output if $?.success?
  raise output
end

def svn(*args)
  runcmd(:svn, *args)
end

def svnadmin(*args)
  runcmd(:svnadmin, *args)
end

def git(*args)
  runcmd(:git, *args)
end

def piston(*args)
  runcmd(:ruby, "-I", PISTON_ROOT + "lib", PISTON_ROOT + "bin/piston", *args)
end
