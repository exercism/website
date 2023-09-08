class Submission::Representation::Create
  include Mandate

  initialize_with :submission, :tooling_job, :ast_digest, :exercise_representer_version

  def call
    representation = Submission::Representation.find_create_or_find_by!(
      submission:,
      ops_status: tooling_job.execution_status.to_i,
      ast_digest:,
      exercise_representer_version:
    ) do |sr|
      sr.tooling_job_id = tooling_job.id
    end

    if representation.id_previously_changed?
      Submission::Representation::UpdateMentor.defer(submission)

      # This is unncessarily most of the time, but should result in a noop downstream if so.
      # We're waiting 10 seconds just to ensure the exercise representation is saved too.
      Solution::UpdatePublishedExerciseRepresentation.defer(submission.solution, wait: 10)
    end

    representation
  end
end
