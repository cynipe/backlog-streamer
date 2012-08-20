# -*- encoding: utf-8 -*-
require 'yammer'
require 'patch/faraday_utils_patch'
require 'pry'

module Backlog
  class Notifier

    attr_reader :yammer
    def initialize(config)
      @yammer = Yammer.new(config)
      raise ArgumentError, "Specified group does not exist: #{config[:group]}" unless group(config[:group])
    end

    def notify(event, watchers)
      origin = find_origin(event)
      if origin
        @yammer.update(format(event, watchers), :group_id => group.id, :replied_to_id => origin.id)
        puts "update found(threaded): #{u.type} #{u.summary}"
      else
        @yammer.update(format(event, watchers), :group_id => group.id)
        puts "update found(new): #{u.type} #{u.summary}"
      end
    end

    def find_origin(event)
      res = @yammer.search("#{event.key}: #{event.summary}")
      puts "#{event.key}: #{event.summary}"
      return nil if res['count'].messages == 0
      res.messages.messages.select {|m| m.group_id == group.id }.sort_by {|m| m.created_at }.first
    end

    private
    def group(group = nil)
      # 微妙にマッチしてない結果も返ってくるので再度名前で一致を取る
      @group ||= @yammer.groups(:letter => group).find {|g| g.name == group}
    end

    def format(event, watchers)
      (<<-MSG).gsub(/^ +/, '')
        #{event.user}によって"#{event.key}: #{event.summary}"が#{event.type}されました。
        https://#{event.space}.backlog.jp/view/#{event.key}

        #{event.content}

        #{"cc: %s" % watchers.map {|w| "@#{w}" }.join(',') unless watchers.empty?}
      MSG
    end

  end
end

