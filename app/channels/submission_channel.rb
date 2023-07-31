class SubmissionChannel < ApplicationCable::Channel
  def subscribed
    stream_from CHANNEL_NAME
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(submission)
    ActionCable.server.broadcast CHANNEL_NAME,
      { submission: SerializeSubmission.(submission) }
  end

  CHANNEL_NAME = "submission".freeze
end
