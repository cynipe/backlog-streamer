require 'fluent-logger'

module Backlog
  module Notifier
    class Fluent < Base

      def initialize(configuration)
        super(configuration)
        @logger = ::Fluent::Logger::FluentLogger.new(self.class.name, :host => configuration[:host], :port => configuration[:port])
      end

      def notify(event)
        hash = event.to_hash
        @logger.post_with_time(configuration[:tag], hash, hash['updated_on'])
      end

    end
  end
end
