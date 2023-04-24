class Submission::AIHelpRecordsChannel < ApplicationCable::Channel
  def subscribed
    # Assert that the user owns this submission
    submission = current_user.submissions.find_by!(uuid: params[:submission_uuid])

    # Don't use persisted objects for stream_for
    stream_for submission.id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(record)
    broadcast_to record.submission_id,
      help_record: {
        source: record.source,
        advice_html: record.advice_html
      }
  end
end
