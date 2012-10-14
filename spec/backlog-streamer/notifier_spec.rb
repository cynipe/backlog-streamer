# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'yammer'

module Backlog
  describe Notifier do

    before do
      @yammer = stub_everything
      Yammer.stubs(:new).returns(@yammer)
      Notifier.any_instance.stubs(:group).returns(stub(:id => 1))
    end

    describe "#notify" do
      let(:notifier) do
        notifier = Notifier.new({})
        notifier.stubs(:build_message)
        notifier
      end

      context "event.typeが課題の場合" do
        it "新規スレッドとして更新する" do
          event = stub(:type => '課題', :summary => '新規課題')
          notifier.expects(:find_origin).never
          @yammer.expects(:update).with(anything, {:group_id => 1})
          notifier.notify(event)
        end
      end

      context "同一のevent.key, event.summaryのスレッドがある場合" do
        it "そのスレッドを更新する" do
          event = stub(:type => '更新', :summary => '課題更新')
          origin = stub(:id => 1)
          notifier.stubs(:find_origin).returns(origin)
          @yammer.expects(:update).with(anything, {:group_id => 1, :replied_to_id => 1})
          notifier.notify(event)
        end
      end

      context "同一のevent.key, event.summaryのスレッドがない場合" do
        it "新規スレッドとして更新する" do
          event = stub(:type => '更新', :summary => '課題更新')
          notifier.stubs(:find_origin).returns(nil)
          @yammer.expects(:update).with(anything, {:group_id => 1})
          notifier.notify(event)
        end
      end
    end

    describe "#build_message" do
      context "新規投稿の場合" do
        let(:notifier) { Notifier.new({}) }
        let(:event) do
          stub(:type     => '更新',
               :space    => 'TEST',
               :key      => 'TST-1',
               :summary  => '概要',
               :content  => '更新内容',
               :user     => 'user1',
               :owner    => 'user1',
               :assigner => 'user1'
              )
        end


        it "課題の概要が含まれている" do
          msg = notifier.send(:build_message, event, true)
          msg.should be_include(event.summary)
        end
        it "課題リンクが含まれている" do
          msg = notifier.send(:build_message, event, true)
          msg.should be_include("https://#{event.space}.backlog.jp/view/#{event.key}")
        end

      end
      context "スレッド投稿の場合" do
        let(:notifier) { Notifier.new({}) }
        let(:event) do
          stub(:type     => '更新',
               :space    => 'TEST',
               :key      => 'TST-1',
               :summary  => '概要',
               :content  => '更新内容',
               :user     => 'user1',
               :owner    => 'user1',
               :assigner => 'user1'
              )
        end

        it "課題の概要が含まれていない" do
          msg = notifier.send(:build_message, event, false)
          msg.should_not be_include(event.summary)
        end
        it "課題リンクが含まれていない" do
          msg = notifier.send(:build_message, event, false)
          msg.should_not be_include("https://#{event.space}.backlog.jp/view/#{event.key}")
        end

      end

      context "作成者、担当者が更新者と同じ場合" do
        let(:notifier) { Notifier.new({}) }
        let(:event) do
          stub(:type     => '更新',
               :space    => 'TEST',
               :key      => 'TST-1',
               :summary  => '概要',
               :content  => '更新内容',
               :user     => 'user1',
               :owner    => 'user1',
               :assigner => 'user1'
              )
        end

        it "通知されない" do
          msg = notifier.send(:build_message, event, false)
          msg.should be_include('[登録者]: user1')
          msg.should be_include('[担当者]: user1')
        end

      end

      context "作成者、担当者が更新者とは別の場合" do
        let(:notifier) { Notifier.new({}) }
        let(:event) do
          stub(:type     => '更新',
               :space    => 'TEST',
               :key      => 'TST-1',
               :summary  => '概要',
               :content  => '更新内容',
               :user     => 'user1',
               :owner    => 'user2',
               :assigner => 'user3'
              )
        end

        it "通知される" do
          msg = notifier.send(:build_message, event, true)
          msg.should be_include('[登録者]: @user2')
          msg.should be_include('[担当者]: @user3')
        end

      end

      context "通知対象者がnotifies_toに指定されていない場合" do
        let(:notifier) { Notifier.new({:notifies_to => ['user2']}) }
        let(:event) do
          stub(:type     => '更新',
               :space    => 'TEST',
               :key      => 'TST-1',
               :summary  => '概要',
               :content  => '更新内容',
               :user     => 'user1',
               :owner    => 'user2',
               :assigner => 'user3'
              )
        end

        it "指定されたもののみ通知される" do
          msg = notifier.send(:build_message, event, true)
          msg.should be_include('[登録者]: @user2')
          msg.should be_include('[担当者]: user3')
        end

      end

    end
  end
end
