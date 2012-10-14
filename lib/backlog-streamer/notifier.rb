# -*- encoding: utf-8 -*-

module Backlog
  module Notifier

    def self.new(notifier, config = {})
      notifier_file = "backlog-streamer/notifier/#{notifier}"
      require(notifier_file)

      notifier_const = notifier.to_s.capitalize.gsub(/_(.)/) { $1.upcase }
      if const_defined?(notifier_const)
        const_get(notifier_const).new(config)
      else
        raise ArgumentError, "could not find `Notifier::#{notifier_const}' in `#{notifier_file}'"
      end
    rescue LoadError
      raise ArgumentError, "could not find any notifier named `#{notifier}'"
    end

  end
end

