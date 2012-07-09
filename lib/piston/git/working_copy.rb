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
        Dir.chdir(self.path) { git(:add, "--force", path.relative_path_from(self.path)) }
      end

      def finalize
        Dir.chdir(path) { git(:add, "--force", ".") }
      end

      def add(added)
        Dir.chdir(path) do
          added.each do |item|
            target = path + item
            target.mkdir unless target.exist?
            git(:add, "-f", item)
          end
        end
      end

      def delete(deleted)
        Dir.chdir(path) do
          deleted.each { |item| git(:rm, "-r", item) }
        end
      end

      def rename(renamed)
        Dir.chdir(path) do
          renamed.each do |from, to|
            target = path + File.dirname(to)
            target.mkpath unless target.exist?
            git(:mv, from, to)
          end
        end
      end

      def downgrade_to(revision)
        logger.debug {"Creating a branch to copy changes from remote repository"}
        Dir.chdir(path) { git(:checkout, '-b', "my-#{revision}", revision) }
      end
      
      def merge_local_changes(revision)
        from_revision = current_revision
        Dir.chdir(path) do
          begin
            logger.debug {"Saving changes in temporary branch"}
            git(:commit, '-a', '-m', '"merging"')
            logger.debug {"Return to previous branch"}
            git(:checkout, revision)
            logger.debug {"Merge changes from temporary branch"}
            git(:merge, '--squash', from_revision)
          rescue Piston::Git::Client::CommandError
            git(:checkout, revision)
          ensure
            logger.debug {"Deleting temporary branch"}
            git(:branch, '-D', from_revision)
          end
        end
      end

      def locally_modified
        logger.debug {"Get last changed revision for #{yaml_path}"}
        # get latest commit for .piston.yml
        initial_revision = last_changed_revision(yaml_path)
        logger.debug {"Get last log line for #{path} after #{initial_revision}"}
        # get latest revisions for this working copy since last update
        Dir.chdir(path) { not git(:log, '-n', '1', "#{initial_revision}..", '.').empty? }
      end

      def exclude_for_diff
        Piston::Git::EXCLUDE
      end

      def status(subpath=nil)
        Dir.chdir(path) do
          git(:status).split("\n").inject([]) do |memo, line|
            next memo unless line =~ /\s(\w+):\s+(.*)$/
            memo << [$1, $2]
          end
        end
      end

      protected
      def current_revision
        Dir.chdir(path) { git(:branch).match(/^\*\s+(.+)$/)[1] }
      end

      def last_changed_revision(path)
        path = Pathname.new(path) unless path.is_a? Pathname
        path = path.relative_path_from(self.path) unless path.relative?
        logger.debug {"Get last log line for #{path}"}
        Dir.chdir(self.path) { git(:log, '-n', '1', path).match(/commit\s+(.*)$/)[1] }
      end
    end
  end
end
