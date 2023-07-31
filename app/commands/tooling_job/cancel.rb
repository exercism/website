class ToolingJob::Cancel
  include Mandate

  initialize_with :submission_uuid, :type

  def call
    return unless job

    job.cancelled!
    update_submission!
  end

  private
  memoize
  def update_submission!
    submission = Submission.find_by!(uuid: submission_uuid)

    case type
    when :test_runner
      submission.tests_cancelled!
    when :representer
      submission.representation_cancelled!
    when :analyzer
      submission.analysis_cancelled!
    end
  end

  def job
    Exercism::ToolingJob.find_for_submission_uuid_and_type(submission_uuid, type)
  rescue StandardError
    nil
  end
end
