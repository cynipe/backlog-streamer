# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'backlog-streamer/notifier'

module Backlog
  describe API do
    include BacklogApiHelpers

    let(:api) { API.new({space:'test', user:'cynipe', pass:'xxxx'}) }

    describe '#get_timeline' do

      context 'when a new issue added' do
        subject do
          prepare_timeline('issue_added')
          api.get_timeline.first
        end

        its(:type) { should == '課題' }
        # 概要と同じものが入ってる
        its(:content) { should == '課題追加の概要' }

        its(:key) { should == 'TEST-3816' }
        its(:user) { should == 'cynipe' }
        its(:updated_on) { should be_an Time }
        its(:summary) { should == '課題追加' }
        its(:description) { should == '課題追加の概要' }
      end

      context 'when the comment added' do
        subject do
          prepare_timeline('comment_added')
          api.get_timeline.first
        end

        # 記述したコメントが入る
        its(:content) { should == '追加したコメント' }

        its(:type) { should == 'コメント' }
        its(:key) { should == 'TEST-3816' }
        its(:user) { should == 'cynipe' }
        its(:updated_on) { should be_an Time }
        its(:summary) { should == 'コメント追加' }
        its(:description) { should == 'コメント追加の概要' }
      end

      %w(状態
        完了理由
        マイルストーン
        発生バージョン
        種別
        カテゴリー
        優先度
        予定時間
        実績時間
        開始日
        期限日
      ).each do |attr|

        context "when #{attr} changed" do
          subject do
            prepare_timeline('attr_changed')
            api.get_timeline.find {|e| e.content.include?(attr) }
          end

          its(:type) { should == '更新' }
          its(:content) { should match /^\[ #{attr}:.* \]$/ }

          its(:key) { should == 'TEST-3816' }
          its(:user) { should == 'cynipe' }
          its(:updated_on) { should be_an Time }
          its(:summary) { should == '課題更新' }
          its(:description) { should == '課題更新の概要' }
        end

        context "when both comment and #{attr} changed" do
          subject do
            prepare_timeline('both_comment_and_attr_changed')
            api.get_timeline.find {|e| e.content.include?(attr) }
          end

          # 属性が変わってる場合は更新になる
          its(:type) { should == '更新' }
          # 更新内容のあとにコメントがつく
          its(:content) { should match /^\[ #{attr}:.* \]\n\n.*$/m }

          its(:key) { should == 'TEST-3816' }
          its(:user) { should == 'cynipe' }
          its(:updated_on) { should be_an Time }
          its(:summary) { should == '課題更新とコメント追加' }
          its(:description) { should == '課題更新とコメント追加の概要' }
        end
      end

    end
  end

end
