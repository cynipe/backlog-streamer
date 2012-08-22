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
      return update(event, watchers) if event.type == '課題'
      origin = find_origin(event)
      origin.nil? ? update(event, watchers) : update_with_thread(event, watchers, origin)
    end

    private
    def group(group = nil)
      # 微妙にマッチしてない結果も返ってくるので再度名前で一致を取る
      @group ||= @yammer.groups(:letter => group).find {|g| g.name == group}
    end

    def find_origin(event)
      res = @yammer.search("#{event.key}: #{event.summary}")
      return nil if res['count'].messages == 0
      res.messages.messages.select {|m| m.group_id == group.id }.sort_by {|m| m.created_at }.first
    end

    def update(event, watchers)
      @yammer.update((<<-MSG).gsub(/^ +/, ''), :group_id => group.id)
        #{event.user}によって"#{event.key}: #{event.summary}"が#{event.type}されました。
        https://#{event.space}.backlog.jp/view/#{event.key}

        #{event.content}

        #{"cc: %s" % watchers.map {|w| "@#{w}" }.join(',') unless watchers.empty?}
      MSG
      puts "update found(new): #{event.type} #{event.summary}"
    end

    def update_with_thread(event, watchers, origin)
        @yammer.update((<<-MSG).gsub(/^ +/, ''), :group_id => group.id, :replied_to_id => origin.id)
          #{event.user}によって#{event.type}されました。

          #{event.content}

          #{"cc: %s" % watchers.map {|w| "@#{w}" }.join(',') unless watchers.empty?}
        MSG
        puts "update found(threaded): #{event.type} #{event.summary}"
    end
  end
end

