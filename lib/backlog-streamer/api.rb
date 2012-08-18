# -*- encoding: utf-8 -*-
require 'xmlrpc/client'
require 'time'

module Backlog
  class TimelineEvent
    attr_reader :space, :type, :content, :updated_on, :user, :key, :summary, :description

    def initialize(space, event)
      @space = space
      @type = event['type']['name']
      @content = event['content']
      @updated_on = Time.parse(event['updated_on'])
      @user = event['user']['name']
      # 今はIssueのイベントしかないので存在しないパターンはないはず
      if event['issue']
        @key = event['issue']['key']
        @summary = event['issue']['summary']
        @description = event['issue']['description']
      end
    end

  end

  class API

    BACKLOG_API = "https://%s.backlog.jp/XML-RPC"

    attr_reader :space

    def initialize(config)
      @space = config[:space]
      @client = XMLRPC::Client.new_from_uri(BACKLOG_API % [space])
      @client.user = config[:user]
      @client.password = config[:pass]
    end

    def get_timeline
      call('backlog.getTimeline').map do |event|
        TimelineEvent.new(space, event)
      end
    end

    def get_issue(key)
      call('backlog.getIssue', key)
    end

    private
    def call(method, args = nil)
      return @client.call(method) unless args
      @client.call(method, args)
    end
  end
end

