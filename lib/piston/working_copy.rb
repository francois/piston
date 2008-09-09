module Piston
  class WorkingCopy
    class UnhandledWorkingCopy < RuntimeError; end
    class NotWorkingCopy < RuntimeError; end

    class << self
      def logger
        @@logger ||= Log4r::Logger["handler"]
      end

      def guess(path)
        path = path.kind_of?(Pathname) ? path : Pathname.new(path.to_s)
        try_path = path.exist? ? path : path.parent
        logger.info {"Guessing the working copy type of #{try_path.inspect}"}
        handler = handlers.detect do |handler|
          logger.debug {"Asking #{handler.name} if it understands #{try_path}"}
          handler.understands_dir?(try_path)
        end

        raise UnhandledWorkingCopy, "Don't know what working copy type #{path} is." if handler.nil?
        handler.new(path)
      end

      @@handlers = Array.new
      def add_handler(handler)
        @@handlers << handler
      end

      def handlers
        @@handlers
      end
      private :handlers
    end

    attr_reader :path

    def initialize(path)
      if path.kind_of?(Pathname)
        raise ArgumentError, "#{path} must be absolute" unless path.absolute?
        @path = path
      else
        @path = Pathname.new(File.expand_path(path))
      end
      logger.debug {"Initialized on #{@path}"}
    end

    def logger
      self.class.logger
    end

    def to_s
      "Piston::WorkingCopy(#{@path})"
    end

    def exist?
      @path.exist? && @path.directory?
    end
    
    def pistonized?
      yaml_path.exist? && yaml_path.file?
    end

    def validate!
      raise NotWorkingCopy unless self.pistonized?
      self
    end

    # Creates the initial working copy for pistonizing a new repository.
    def create
      logger.debug {"Creating working copy at #{path}"}
    end

    # Copy files from +revision+.  +revision+ must
    # #respond_to?(:each), and return each file that is to be copied.
    # Only files must be returned.
    #
    # Each item yielded by Revision#each must be a relative path.
    #
    # WorkingCopy will call Revision#copy_to with the full path to where the
    # file needs to be copied.
    def copy_from(revision)
      revision.each do |relpath|
        target = path + relpath
        target.dirname.mkdir rescue nil

        logger.debug {"Copying #{relpath} to #{target}"}
        revision.copy_to(relpath, target)
      end
    end

    # Stores a Hash of values that can be retrieved later.
    def remember(values, handler_values)
      values["format"] = 1

      # Stringify keys
      values.keys.each do |key|
        values[key.to_s] = values.delete(key)
      end

      logger.debug {"Remembering #{values.inspect} as well as #{handler_values.inspect}"}
      File.open(yaml_path, "w+") do |f|
        f.write(values.merge("handler" => handler_values).to_yaml)
      end

      logger.debug {"Calling \#after_remember on #{yaml_path}"}
      after_remember(yaml_path)
    end

    # Callback after #remember is done, to do whatever the
    # working copy needs to do with the file.
    def after_remember(path)
    end

    # Recalls a Hash of values from the working copy.
    def recall
      YAML.load_file(yaml_path)
    end

    def finalize
      logger.debug {"Finalizing #{path}"}
    end
    
    # Returns basic information about this working copy.
    def info
      recall
    end

    def import(revision, lock)
      repository = revision.repository
      tmpdir = temp_dir_name
      begin
        logger.info {"Checking out the repository"}
        revision.checkout_to(tmpdir)

        logger.debug {"Creating the local working copy"}
        create

        logger.info {"Copying from #{revision}"}
        copy_from(revision)

        logger.debug {"Remembering values"}
        remember(
          {:repository_url => repository.url, :lock => lock, :repository_class => repository.class.name},
          revision.remember_values
        )

        logger.debug {"Finalizing working copy"}
        finalize

        logger.info {"Checked out #{repository.url.inspect} #{revision.name} to #{path.to_s}"}
      ensure
        logger.debug {"Removing temporary directory: #{tmpdir}"}
        tmpdir.rmtree rescue nil
      end
    end

    # Update this working copy from +from+ to +to+, which means merging local changes back in
    def update(to, lock)
      tmpdir = temp_dir_name
      begin
        to.checkout_to(tmpdir)
        do_update(to, lock)
      ensure
        logger.debug {"Removing temporary directory: #{tmpdir}"}
        tmpdir.rmtree rescue nil
      end
    end

    def temp_dir_name
      path.parent + ".#{path.basename}.tmp"
    end

    protected
    def do_update(to, lock)
      raise NotImplementedError
    end

    # The path to the piston YAML file.
    def yaml_path
      path + ".piston.yml"
    end
  end
end
