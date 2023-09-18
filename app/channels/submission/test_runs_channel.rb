class Submission::TestRunsChannel < ApplicationCable::Channel
  def subscribed
    submission = current_user.submissions.find_by!(uuid: params[:submission_uuid])

    # Don't use persisted objects for stream_for
    stream_for submission.id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast!(test_run)
    broadcast_to test_run.submission_id,
      test_run: SerializeSubmissionTestRun.(test_run)
  end
end
