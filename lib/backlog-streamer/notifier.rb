# -*- encoding: utf-8 -*-
require 'yammer'

module Backlog
  class Notifier

    def initialize(config)
      @yammer = Yammer.new(config)
      raise ArgumentError, "Specified group does not exist: #{config[:group]}" unless group(config[:group])
    end

    def notify(event, watchers)
      @yammer.update(format(event, watchers), :group_id => group.id)
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

