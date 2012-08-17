# -*- encoding: utf-8 -*-
require 'yammer'

module Backlog
  class Notifier

    def initialize(config)
      @yammer = Yammer.new(config)
      raise ArgumentError, "Specified group does not exist: #{config[:group]}" unless group(config[:group])
    end

    def notify(timeline)
      @yammer.update(timeline.to_s, :group_id => group.id)
    end

    def group(group = nil)
      # 微妙にマッチしてない結果も返ってくるので再度名前で一致を取る
      @group ||= @yammer.groups(:letter => group).find {|g| g.name == group}
    end

  end
end

