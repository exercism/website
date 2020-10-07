class TestRunChannel < ApplicationCable::Channel
  def subscribed
    stream_from CHANNEL_NAME
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(test_run)
    ActionCable.server.broadcast CHANNEL_NAME, test_run: SerializeSubmissionTestRun.(test_run)
  end

  CHANNEL_NAME = "test_run".freeze
end
