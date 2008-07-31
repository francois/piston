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

      def finalize
        Dir.chdir(path) { git(:add, ".") }
      end

      def update(from, to, todir)
        Dir.chdir(todir) do
          git(:checkout, "-b", "mine", from.commit)
        end
        puts "todir: #{todir}"
        puts "exist? #{todir.exist?}"
        puts "file? #{todir.file?}"
        puts "directory? #{todir.directory?}"
        (todir + "*").children.reject {|item| item == ".git"}.each {|item| puts "rm -rf #{item}"; FileUtils.rm_rf(item)}
        (path + "*").chidlren.reject {|item| item == ".git"}.each {|item| puts "cp -r #{item}"; FileUtils.cp_r(item, todir)}
        Dir.chdir(todir) do
          git(:add, ".")
          deletions = git(:status).split("\n").grep(/deleted:/).map {|row| row.split(":", 2).last}
          git(:rm, *deletions) unless deletions.empty?
          `gitk --all`
          git(:commit, "-m", "my local changes based on #{from.commit}")
          git(:rebase, to.branch_name)
        end
      end
    end
  end
end
