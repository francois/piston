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
        svn(:mkdir, path)
      end

      def after_remember(path)
        info = svn(:info, path)
        return unless info =~ /\(not a versioned resource\)/i || info.empty?
        svn(:add, path)
      end

      def finalize
        targets = []
        Dir[path + "*"].each do |item|
          svn(:add, item)
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

      def update(from, to, todir)
        copy_from(to)
        merge_changes(from, to, todir)
      end

      def merge_changes(from, to, todir)
        data = svn(:info, path + "/.piston.yml")
        info = YAML.load(data)
        initial_revision = info["Last Changed Rev"].to_i.succ
        svn(:merge, "--revision", "#{initial_revision}:#{to.revision}", from.url, path)
      end

      def remove_external_references(*targets)
        svn(:propdel, "svn:externals", *targets)
      end
    end
  end
end
