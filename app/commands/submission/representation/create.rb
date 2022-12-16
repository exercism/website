class Submission::Representation::Create
  include Mandate

  initialize_with :submission, :tooling_job, :ast_digest

  def call
    representation = submission.create_submission_representation!(
      tooling_job_id: tooling_job.id,
      ops_status: tooling_job.execution_status.to_i,
      ast_digest:
    )

    Submission::Representation::UpdateMentor.defer(submission)

    representation
  end
end
