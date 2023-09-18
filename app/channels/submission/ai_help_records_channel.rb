class Submission::AIHelpRecordsChannel < ApplicationCable::Channel
  def subscribed
    submission = current_user.submissions.find_by!(uuid: params[:submission_uuid])

    # Don't use persisted objects for stream_for
    stream_for submission.uuid
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(record, submission_uuid, user)
    broadcast_to submission_uuid,
      help_record: SerializeSubmissionAIHelpRecord.(record),
      usage: user.chatgpt_usage
  end
end
