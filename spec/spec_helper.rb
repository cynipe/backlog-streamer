$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rspec'
require 'pry'
require 'webmock/rspec'
require 'backlog-streamer'

module FixtureHelpers
  def timeline_response(name)
    load_fixture("backlog/timeline/#{name}.xml")
  end

  def load_fixture(spec)
    @@config_fixture_loaders ||= {}
    @@config_fixture_loaders[spec] ||= File.read(File.dirname(__FILE__) + "/fixtures/#{spec}")
    @@config_fixture_loaders[spec]
  end

end

module BacklogApiHelpers
  include FixtureHelpers

  def prepare_timeline(fixture, status = 200)
    stub_request(:post, "https://cynipe:xxxx@test.backlog.jp/XML-RPC").
         with(:body => "<?xml version=\"1.0\" ?><methodCall><methodName>backlog.getTimeline</methodName><params/></methodCall>\n",
              :headers => {'Accept'=>'*/*', 'Connection'=>'keep-alive', 'Content-Length'=>'101', 'Content-Type'=>'text/xml; charset=utf-8'}).
        to_return(:status => status,
                  :body => timeline_response(fixture),
                  :headers => {'Content-Type'=>'text/xml; charset=utf-8' })
  end

end

