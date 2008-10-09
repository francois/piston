require "piston/working_copy"
require "piston/git/client"

module Piston
  module Git
    class WorkingCopy < Piston::WorkingCopy
      # Register ourselves as a handler for working copies
      Piston::WorkingCopy.add_handler self

      class << self
        def understands_dir?(dir)
          path = dir
          begin
            begin
              logger.debug {"git status on #{path}"}
              Dir.chdir(path) do
                response = git(:status)
                return true if response =~ /# On branch /
              end
            rescue Errno::ENOENT
              # NOP, we assume this is simply because the folder hasn't been created yet
              path = path.parent
              retry unless path.to_s == "/"
              return false
            end
          rescue Piston::Git::Client::BadCommand
            # NOP, as we return false below
          rescue Piston::Git::Client::CommandError
            # This is certainly not a Git repository
            false
          end

          false
        end

        def client
          @@client ||= Piston::Git::Client.instance
        end

        def git(*args)
          client.git(*args)
        end
      end

      def git(*args)
        self.class.git(*args)
      end

      def create
        path.mkpath rescue nil
      end

      def exist?
        path.directory?
      end

      def after_remember(path)
        Dir.chdir(self.path) { git(:add, path.relative_path_from(self.path)) }
      end

      def finalize
        Dir.chdir(path) { git(:add, ".") }
      end

      def copy_from(revision)
        super
        Dir.chdir(path) { git(:add, "-u") }
      end

      def add(added)
        Dir.chdir(path) do
          added.each { |item| git(:add, item) }
        end
      end

      def delete(deleted)
        Dir.chdir(path) do
          deleted.each { |item| git(:rm, item) }
        end
      end

      def rename(renamed)
        Dir.chdir(path) do
          renamed.each { |from, to| git(:mv, from, to) }
        end
      end
      
      def update(revision, to, lock)
        tmpdir = temp_dir_name
        begin
          logger.info {"Checking out the repository at #{to.revision}"}
          to.checkout_to(tmpdir)
        ensure
          logger.debug {"Removing temporary directory: #{tmpdir}"}
          tmpdir.rmtree rescue nil
        end
        super
      end

      def locally_modified
        Dir.chdir(path) do
          # get latest commit for .piston.yml
          data = git(:log, '-n', '1', yaml_path.relative_path_from(path))
          initial_revision = data.match(/commit\s+(.*)$/)[1]
          # get latest revisions for this working copy since last update
          log = git(:log, '-n', '1', "#{initial_revision}..")
          not log.empty?
        end
      end
    end
  end
end
