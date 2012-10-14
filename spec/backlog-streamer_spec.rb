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

  end
end


