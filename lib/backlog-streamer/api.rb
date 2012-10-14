# -*- encoding: utf-8 -*-
require 'xmlrpc/client'
require 'time'

module Backlog
  class TimelineEvent
    attr_reader :space, :type, :content, :updated_on, :user, :key, :summary, :description, :owner, :assigner

    def initialize(space, owner, assigner, event)
      @space = space
      @owner = owner
      @assigner = assigner
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
      raise ArgumentError, "space must be specified." unless config[:space]
      raise ArgumentError, "user must be specified." unless config[:user]
      raise ArgumentError, "pass must be specified." unless config[:pass]
      @space = config[:space]
      @client = XMLRPC::Client.new_from_uri(BACKLOG_API % [space])
      @client.user = config[:user]
      @client.password = config[:pass]
    end

    def get_timeline
      call('backlog.getTimeline').map do |event|
        origin = get_issue(event['issue']['key'])
        owner = origin['created_user']['name']
        assigner = origin['assigner'] ? origin['assigner']['name'] : nil

        TimelineEvent.new(space, owner, assigner, event)
      end
    end

    def get_issue(key)
      call('backlog.getIssue', key)
    end

    private
    def call(method, args = nil, times = 5)
      times -=1
      return @client.call(method) unless args
      @client.call(method, args)
    rescue Timeout::Error => e
      raise e if times == 0
      puts "timeout retrying..."
      retry
    end
  end
end

