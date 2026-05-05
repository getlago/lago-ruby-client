# frozen_string_literal: true

require 'logger'

module Lago
  module Api
    # Ready-to-use +on_rate_limit_info+ callable that logs a warning each time
    # rate limit usage crosses one of the configured thresholds.
    #
    # Example:
    #   client = Lago::Api::Client.new(
    #     api_key: '...',
    #     on_rate_limit_info: Lago::Api::LoggingRateLimitObserver.new,
    #   )
    class LoggingRateLimitObserver
      DEFAULT_THRESHOLDS = [0.80, 0.90, 0.95].freeze

      def initialize(thresholds: DEFAULT_THRESHOLDS, logger: nil, level: Logger::WARN)
        @thresholds = thresholds.sort.reverse
        @logger = logger || default_logger
        @level = level
      end

      def call(info)
        pct = info.usage_pct
        return if pct.nil?

        return unless @thresholds.any? { |threshold| pct >= threshold }

        @logger.add(
          @level,
          format(
            'Lago rate limit at %<pct>.0f%% (limit=%<limit>s, remaining=%<remaining>s, ' \
            'reset=%<reset>ss, %<method>s %<url>s)',
            pct: pct * 100,
            limit: info.limit.inspect,
            remaining: info.remaining.inspect,
            reset: info.reset.inspect,
            method: info.method,
            url: info.url,
          ),
        )
      end

      private

      def default_logger
        logger = Logger.new($stderr)
        logger.progname = 'lago_ruby_client.rate_limit'
        logger
      end
    end
  end
end
