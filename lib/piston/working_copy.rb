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
        handler.new(File.expand_path(path))
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

    def repository
      values = self.recall
      repository_class = values["repository_class"]
      repository_url = values["repository_url"]
      repository_class.constantize.new(repository_url)
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

    # Copy files to +revision+ to keep local changes.  +revision+ must
    # #respond_to?(:each), and return each file that is to be copied.
    # Only files must be returned.
    #
    # Each item yielded by Revision#each must be a relative path.
    #
    # WorkingCopy will call Revision#copy_from with the full path from where the
    # file needs to be copied.
    def copy_to(revision)
      revision.each do |relpath|
        source = path + relpath

        logger.debug {"Copying #{source} to #{relpath}"}
        revision.copy_from(source, relpath)
      end
    end

    # add some files to working copy
    def add(added)
      raise SubclassResponsibilityError, "Piston::WorkingCopy#add should be implemented by a subclass."
    end

    # delete some files from working copy
    def delete(deleted)
      raise SubclassResponsibilityError, "Piston::WorkingCopy#delete should be implemented by a subclass."
    end

    # rename some files in working copy
    def rename(renamed)
      raise SubclassResponsibilityError, "Piston::WorkingCopy#rename should be implemented by a subclass."
    end

    # Downgrade this working copy to +revision+.
    def downgrade_to(revision)
      raise SubclassResponsibilityError, "Piston::WorkingCopy#downgrade_to should be implemented by a subclass."
    end

    # Merge remote changes with local changes in +revision+.
    def merge_local_changes(revision)
      raise SubclassResponsibilityError, "Piston::WorkingCopy#merge_local_changes should be implemented by a subclass."
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
      lock ||= false
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
    # Return true if changed, false if not
    def update(revision, to, lock)
      lock ||= false
      tmpdir = temp_dir_name
      begin
        logger.info {"Checking out the repository at #{revision.revision}"}
        revision.checkout_to(tmpdir)

        revision_to_return = current_revision
        revision_to_downgrade = last_changed_revision(yaml_path)
        logger.debug {"Downgrading to #{revision_to_downgrade}"}
        downgrade_to(revision_to_downgrade)

        logger.debug {"Copying old changes to temporary directory in order to keep them"}
        copy_to(revision)

        logger.info {"Looking changes from #{revision.revision} to #{to.revision}"}
        added, deleted, renamed = revision.update_to(to.revision)

        logger.info {"Updating working copy"}

        # rename before copy because copy_from will copy these files
        logger.debug {"Renaming files"}
        rename(renamed)

        logger.debug {"Copying files from temporary directory"}
        copy_from(revision)

        logger.debug {"Adding new files to version control"}
        add(added)

        logger.debug {"Deleting files from version control"}
        delete(deleted)

        # merge local changes updating to revision before downgrade was made
        logger.debug {"Merging local changes"}
        merge_local_changes(revision_to_return)

        remember(recall.merge(:lock => lock), to.remember_values)

        status = status(path)
        logger.debug { {:added => added, :deleted => deleted, :renamed => renamed, :status => status}.to_yaml }
        !status.empty?
      ensure
        logger.debug {"Removing temporary directory: #{tmpdir}"}
        tmpdir.rmtree rescue nil
      end
    end

    def diff
      tmpdir = temp_dir_name
      begin
        logger.info {"Checking out the repository at #{revision.revision}"}
        revision = repository.at(:head)
        revision.checkout_to(tmpdir)

        excludes = (['.piston.yml'] + exclude_for_diff + revision.exclude_for_diff).uniq.collect {|pattern| "--exclude=#{pattern}"}.join ' '
        system("diff -urN #{excludes} '#{tmpdir}' '#{path}'")
      ensure
        logger.debug {"Removing temporary directory: #{tmpdir}"}
        tmpdir.rmtree rescue nil
      end
    end

    def diff
      tmpdir = temp_dir_name
      begin
        logger.info {"Checking out the repository at #{revision.revision}"}
        revision = repository.at(:head)
        revision.checkout_to(tmpdir)

        excludes = (['.piston.yml'] + exclude_for_diff + revision.exclude_for_diff).uniq.collect {|pattern| "--exclude=#{pattern}"}.join ' '
        system("diff -urN #{excludes} '#{tmpdir}' '#{path}'")
      ensure
        logger.debug {"Removing temporary directory: #{tmpdir}"}
        tmpdir.rmtree rescue nil
      end
    end

    def temp_dir_name
      path.parent + ".#{path.basename}.tmp"
    end

    def locally_modified
      raise SubclassResponsibilityError, "Piston::WorkingCopy#locally_modified should be implemented by a subclass."
    end

    def remotely_modified
      repository.at(recall["handler"]).remotely_modified
    end

    def exclude_for_diff
      raise SubclassResponsibilityError, "Piston::WorkingCopy#exclude_for_diff should be implemented by a subclass."
    end

    protected
    # The path to the piston YAML file.
    def yaml_path
      path + ".piston.yml"
    end

    # The current revision of this working copy.
    def current_revision
      raise SubclassResponsibilityError, "Piston::WorkingCopy#current_revision should be implemented by a subclass."
    end

    # The last revision which +path+ was changed in
    def last_changed_revision(path)
      raise SubclassResponsibilityError, "Piston::WorkingCopy#last_changed_revision should be implemented by a subclass."
    end
  end
end
