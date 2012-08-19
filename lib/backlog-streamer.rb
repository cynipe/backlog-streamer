# -*- encoding: utf-8 -*-
require 'daemon_spawn'
require 'yaml'

module Backlog
  autoload :API, 'backlog-streamer/api'
  autoload :Notifier, 'backlog-streamer/notifier'

  class Streamer < DaemonSpawn::Base

    VERSION = "0.0.3"
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
            notifier.notify(u, watchers(u))
            puts "update found: #{u.type} #{u.summary}"
            sleep 3
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
      @config ||= to_symbolized_hash(YAML.load_file(STREAMER_ROOT + 'config/config.yml'))
    end

    def api
      @api ||= API.new(config[:backlog])
    end

    def notifier
      @notifier ||= Notifier.new(config[:yammer])
    end

    def to_symbolized_hash(orig)
      orig.reduce({}) do |mem, (key, val)|
        mem[key.to_sym] = (val.kind_of? Hash) ? to_symbolized_hash(val) : val
        mem
      end
    end

    def watchers(event)
      return [] unless event.key
      issue = api.get_issue(event.key)
      return [] if issue.empty?

      owner = issue['created_user']['name']
      assigner = issue['assigner'] ? issue['assigner']['name'] : nil

      res = []
      res <<  owner unless owner == event.user
      res <<  assigner if assigner and not assigner == event.user
      res.uniq
    end

  end
end

