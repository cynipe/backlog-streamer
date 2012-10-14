# -*- encoding: utf-8 -*-
require 'yammer'
require 'patch/faraday_utils_patch'
require 'pry'

module Backlog
  class Notifier

    attr_reader :yammer

    def initialize(config)
      @config = config
      @yammer = Yammer.new(config)
      raise ArgumentError, "Specified group does not exist: #{config[:group]}" unless group(config[:group])
    end

    def notify(event)
      opts = { :group_id => group.id }
      origin = find_origin(event) unless event.type == '課題'
      opts.merge!({:replied_to_id => origin.id }) if origin
      @yammer.update(build_message(event, origin.nil?), opts)
      puts "update: #{event.type} #{event.summary}"
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

    def decorate(name, event_user)
      return nil unless name
      # notifies_toが指定されていない場合は通知対象になる
      notifies_to = @config[:notifies_to] ? @config[:notifies_to] : [name]
      (name != event_user and notifies_to.include? name) ? "@#{name}" : name
    end

    def build_message(event, new)
      msg = StringIO.new
      if new
        msg << "#{event.user}によって'#{event.key}: #{event.summary}'が#{event.type}されました。\n"
        msg << "https://#{event.space}.backlog.jp/view/#{event.key}"
      else
        msg << "#{event.user}によって#{event.type}されました。\n"
      end
      msg << "\n#{event.content}\n"
      msg << "[登録者]: #{decorate(event.owner, event.user)}\t"
      msg << "[担当者]: #{decorate(event.assigner, event.user)}" if event.assigner
      msg.string
    end

  end
end

