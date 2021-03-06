# -*- encoding: utf-8 -*-
require 'daemon_spawn'
require 'yaml'

module Backlog
  autoload :API, 'backlog-streamer/api'
  autoload :Notifier, 'backlog-streamer/notifier'

  class Streamer < DaemonSpawn::Base

    VERSION = "0.0.5"
    STREAMER_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__) + '/..'))

    def initialize(args)
      super(args)
      @last_updated = nil
    end

    def start(args)
      puts "backlog streamer started."
      loop do
        updates = api.get_timeline.sort_by {|t| t.updated_on }.
          tap {|tl| @last_updated ||= tl.last.updated_on }.
          select {|t| t.updated_on > @last_updated }

        unless updates.empty?
          @last_updated = updates.last.updated_on
          updates.each do |u|
            notifiers.each {|n| n.notify(u) }
          end
        end
        sleep 10
      end
    end

    def stop
      puts "backlog streamer successfully terminated."
    end

    private
    def config
      @config ||= YAML.load_file(STREAMER_ROOT + 'config/config.yml')
    end

    def api
      @api ||= API.new(config[:backlog])
    end

    def notifiers
      @notifiers ||= config[:notifiers].map do |config|
        type = config.delete(:type)
        Notifier.new(type, config)
      end
    end
  end
end

