require "yaml"

module Piston
  module Svn
    class WorkingCopy < Piston::WorkingCopy
      # Register ourselves as a handler for working copies
      Piston::WorkingCopy.add_handler self

      class << self
        def understands_dir?(dir)
          result = svn(:info, dir) rescue :failed
          result == :failed ? false : true
        end

        def client
          @@client ||= Piston::Svn::Client.instance
        end

        def svn(*args)
          client.svn(*args)
        end

        def old_repositories(*directories)
          repositories = []
          unless directories.empty?
            folders = svn(:propget, '--recursive', Piston::Svn::ROOT, *directories)
            folders.each_line do |line|
              next unless line =~ /^(.+) - \S+/
              logger.debug {"Found repository #{$1}"}
              repositories << $1
            end
          end
          repositories
        end
      end

      def svn(*args)
        self.class.svn(*args)
      end

      def exist?
        result = svn(:info, path) rescue :failed
        logger.debug {"result: #{result.inspect}"}
        return false if result == :failed
        return false if result.nil? || result.chomp.strip.empty?
        return true if YAML.load(result).has_key?("Path")
      end

      def create
        logger.debug {"Creating #{path}"}
        begin
          svn(:mkdir, path)
        rescue Piston::Svn::Client::CommandError
          logger.error do
            "Folder #{path} could not be created.  Is #{path.parent} a working copy? (Tip: svn mkdir it)"
          end
          raise
        end
      end

      def after_remember(path)
        begin
          info = svn(:info, path)
        rescue Piston::Svn::Client::CommandError
        ensure
          return unless info =~ /\(not a versioned resource\)/i || info =~ /\(is not under version control\)/i || info.blank?
          svn(:add, path)
        end
      end

      def finalize
        targets = []
        Dir[(path + "*").to_s].each do |item|
          svn(:add, item)
        end
      end

      def add(added)
        added.each do |item|
          target = path + item
          target.mkdir unless target.exist?
          svn(:add, target)
        end
      end

      def delete(deleted)
        deleted.each do |item|
          svn(:rm, path + item)
        end
      end

      def rename(renamed)
        renamed.each do |from, to|
          svn(:mv, path + from, path + to)
        end
      end

      def downgrade_to(revision)
        logger.debug {"Downgrading to revision when last update was made"}
        svn(:update, '--revision', revision, path)
      end

      def merge_local_changes(revision)
        logger.debug {"Update to #{revision} in order to merge local changes"}
        svn(:update, path)
      end

      def status(subpath=nil)
        svn(:status, path + subpath.to_s).split("\n").inject([]) do |memo, line|
          next memo unless line =~ /^\w.+\s(.*)$/
          memo << [$1, $2]
        end
      end

      # Returns all defined externals (recursively) of this WC.
      # Returns a Hash:
      #   {"vendor/rails" => {:revision => :head, :url => "http://dev.rubyonrails.org/svn/rails/trunk"},
      #    "vendor/plugins/will_paginate" => {:revision => 1234, :url => "http://will_paginate.org/svn/trunk"}}
      def externals
        externals = svn(:proplist, "--recursive", "--verbose")
        return Hash.new if externals.blank?
        returning(Hash.new) do |result|
          YAML.load(externals).each_pair do |dir, props|
            next if props["svn:externals"].blank?
            next unless dir =~ /Properties on '([^']+)'/
            basedir = self.path + $1
            exts = props["svn:externals"]
            exts.split("\n").each do |external|
              data = external.match(/^([^\s]+)\s+(?:(?:-r|--revision)\s*(\d+)\s+)?(.+)$/)
              case data.length
              when 4
                subdir, rev, url = data[1], data[2].nil? ? :head : data[2].to_i, data[3]
              else
                raise SyntaxError, "Could not parse svn:externals on #{basedir}: #{external}"
              end

              result[basedir + subdir] = {:revision => rev, :url => url}
            end
          end
        end
      end

      def remove_external_references(*targets)
        svn(:propdel, "svn:externals", *targets)
      end

      def locally_modified
        logger.debug {"Get last changed revision for #{yaml_path}"}
        # get latest revision for .piston.yml
        initial_revision = last_changed_revision(yaml_path)
        logger.debug {"Get last log line for #{path} after #{initial_revision}"}
        # get latest revisions for this working copy since last update
        log = svn(:log, '--revision', "#{initial_revision}:HEAD", '--quiet', '--limit', '2', path)
        log.count("\n") > 3
      end

      def exclude_for_diff
        Piston::Svn::EXCLUDE
      end

      def upgrade
        props = Hash.new
        svn(:proplist, '--verbose', path).each_line do |line|
          if line =~ /(piston:[-\w]+)\s*:\s*(.*)$/
            props[$1] = $2
            svn(:propdel, $1, path)
          end
        end
        remember({:repository_url => props[Piston::Svn::ROOT], :lock => props[Piston::Svn::LOCKED] || false, :repository_class => Piston::Svn::Repository.name}, {Piston::Svn::REMOTE_REV => props[Piston::Svn::REMOTE_REV], Piston::Svn::UUID => props[Piston::Svn::UUID]})
      end

      protected
      def current_revision
        data = svn(:info, path)
        YAML.load(data)["Revision"].to_i
      end

      def last_changed_revision(path)
        data = svn(:info, yaml_path)
        YAML.load(data)["Last Changed Rev"].to_i
      end
    end
  end
end
