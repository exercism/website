class Submission::AIHelpRecordsChannel < ApplicationCable::Channel
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
      help_record: SerializeSubmissionAIHelpRecord.(record),
      usage: user.usages['chatgpt']
  end
end
