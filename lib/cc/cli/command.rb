require "highline"
require "active_support"
require "active_support/core_ext"
require "rainbow"

module CC
  module CLI
    class Command
      CODECLIMATE_YAML = ".codeclimate.yml".freeze

      attr_reader :logger

      def initialize(args = [], logger = TerminalLogger.new)
        @args = args
        @logger = logger
      end

      def run
        logger.error("unknown command #{self.class.name.split('::').last.underscore}")
      end

      def self.command_name
        name[/[^:]*$/].split(/(?=[A-Z])/).map(&:downcase).join("-")
      end

      def execute
        run
      end

      def success(message)
        say(colorize(message, :green))
      end

      def say(message)
        logger.info(message)
      end

      def warn(message)
        say(colorize("WARNING: #{message}", :yellow))
      end

      def fatal(message)
        logger.fatal(colorize(message, :red))
        exit 1
      end

      def require_codeclimate_yml
        unless filesystem.exist?(CODECLIMATE_YAML)
          fatal("No '.codeclimate.yml' file found. Run 'codeclimate init' to generate a config file.")
        end
      end

      private

      def colorize(string, *args)
        rainbow.wrap(string).color(*args)
      end

      def rainbow
        @rainbow ||= Rainbow.new
      end

      def filesystem
        @filesystem ||= CC::Analyzer::Filesystem.new(ENV["FILESYSTEM_DIR"])
      end

      def terminal
        @terminal ||= HighLine.new($stdin, $stdout)
      end

      def engine_registry
        @engine_registry ||= CC::Analyzer::EngineRegistry.new
      end
    end
  end
end
