class Submission::Representation::Create
  include Mandate

  initialize_with :submission, :tooling_job, :ast_digest, :exercise_representer_version

  def call
    Submission::Representation.create!(
      submission:,
      tooling_job_id: tooling_job.id,
      ops_status: tooling_job.execution_status.to_i,
      ast_digest:,
      exercise_representer_version:
    ).tap do
      Submission::Representation::UpdateMentor.defer(submission)
    end
  end
end
