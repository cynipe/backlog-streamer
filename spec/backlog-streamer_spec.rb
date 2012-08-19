# -*- encoding: utf-8 -*-
require 'spec_helper'

module Backlog
  describe Streamer do

    let(:api) { mock }
    let(:notifier) { mock }
    let(:streamer) do
      streamer = Streamer.new({:working_dir=> ".",
                    :pid_file=>"./backlog-streamer.pid",
                    :log_file=>"./backlog-streamer.log",
                    :sync_log=>true,
                    :singleton=>true,
                    :index=>0})
      streamer.stubs(:api).returns(api)
      streamer.stubs(:notifier).returns(api)
      streamer
    end

    describe '#watchers' do
      let(:event)  { mock }

      it 'returns an empty array if event has no issue key' do
        event.stubs(:key).returns(nil)
        api.expects(:get_issue).never
        streamer.send(:watchers, event).should == []
      end

      it 'returns an empty array if event has non-existing issue key' do
        event.stubs(:key).returns('TEST-0')
        api.expects(:get_issue).returns({})
        streamer.send(:watchers, event).should == []
      end

      it 'returns owner only if issue has no assigner' do
        api.expects(:get_issue).
            returns({ 'created_user' => { 'name' => 'owner' },
                      'assigner'     => nil })
        event.stubs(:key).returns('TEST-1')
        event.stubs(:user).returns('cynipe')
        streamer.send(:watchers, event).should == ['owner']
      end

      it 'returns both owner and assigner if issue has an assigner' do
        api.expects(:get_issue).
            returns({ 'created_user' => { 'name' => 'owner' },
                      'assigner'     => { 'name' => 'assigner'} })
        event.stubs(:key).returns('TEST-1')
        event.stubs(:user).returns('cynipe')
        streamer.send(:watchers, event).should == ['owner', 'assigner']
      end

      it 'returns assigner only if owner is same as the event user' do
        api.expects(:get_issue).
            returns({ 'created_user' => { 'name' => 'owner' },
                      'assigner'     => { 'name' => 'assigner' } })
        event.stubs(:key).returns('TEST-1')
        event.stubs(:user).returns('owner')
        streamer.send(:watchers, event).should == ['assigner']
      end

      it 'returns owner only if assigner is same as the event user' do
        api.expects(:get_issue).
            returns({ 'created_user' => { 'name' => 'owner' },
                      'assigner'     => { 'name' => 'assigner' } })
        event.stubs(:key).returns('TEST-1')
        event.stubs(:user).returns('assigner')
        streamer.send(:watchers, event).should == ['owner']
      end

      it 'returns an empty array if both owner and assigner are same as the event user' do
        api.expects(:get_issue).
            returns({ 'created_user' => { 'name' => 'cynipe' },
                      'assigner'     => { 'name' => 'cynipe' }})
        event.stubs(:key).returns('TEST-1')
        event.stubs(:user).returns('cynipe')
        streamer.send(:watchers, event).should == []
      end
    end


  end
end


