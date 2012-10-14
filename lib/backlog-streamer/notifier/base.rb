# -*- encoding: utf-8 -*-

module Backlog
  module Notifier
    class Base
      attr_reader :configuration

      def initialize(configuration = {})
        @configuration = configuration
      end

      def notify(event)
        raise NotImplementedError, "`notify' is not implemented by #{self.class.name}"
      end

    end
  end
end
