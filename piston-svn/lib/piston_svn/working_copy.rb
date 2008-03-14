require "piston_core/working_copy"
require "piston_svn"
require "piston_svn/client"
require "yaml"

module PistonSvn
  class WorkingCopy < PistonCore::WorkingCopy
    extend PistonSvn::Client

    class << self
      def understands_dir?(dir)
        result = svn(:info, dir) rescue :failed
        result == :failed ? false : true
      end
    end

    def svn(*args)
      self.class.svn(*args)
    end

    def svnadmin(*args)
      self.class.svnadmin(*args)
    end

    def exist?
      logger.debug {"svn info on #{path}"}
      result = svn(:info, path) rescue :failed
      logger.debug {"result: #{result.inspect}"}
      result == :failed ? false : true
    end

    def create
      info = YAML.load(svn(:info, path.parent))
      local_rev = info["Last Changed Rev"]
      svn(:mkdir, path)
      svn(:propset, PistonSvn::LOCAL_REV, local_rev, path)
    end

    def copy_from(revision)
      revision.each do |relpath|
        target = path + relpath
        target.dirname.mkdir rescue nil

        logger.debug {"Copying #{relpath} to #{target}"}
        revision.copy_to(relpath, target)
      end
    end

    def remember(values)
      values.each_pair do |k, v|
        svn(:propset, k, v, path)
      end
    end

    def recall(keys)
      hash = Hash.new
      keys.each do |k|
        hash[k] = svn(:propget, k, path)
      end

      hash
    end

    def finalize
      targets = []
      Dir[path + "*"].each do |item|
        svn(:add, item)
      end
    end
  end
end
