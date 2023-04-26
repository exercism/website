class AIHelpRecordsChannel < ApplicationCable::Channel
  def subscribed
    # Assert that the user owns this submission
    submission = Submission.find_by!(uuid: params[:submission_uuid])

    # Don't use persisted objects for stream_for
    stream_for submission.uuid
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(record, submission_uuid)
    broadcast_to submission_uuid,
      help_record: {
        source: record.source,
        advice_html: record.advice_html
      }
  end
end
