def svnadmin(*args)
  run(:svnadmin, args)
end

def svn(*args)
  run(:svn, args)
end

def run(program, args)
  cmd = args.map{|o| o.to_s}.inject([program]) do |memo, arg|
    memo << (arg.include?(" ") ? %Q("#{arg}") : arg)
  end
  `#{cmd.join(" ")}`
end
