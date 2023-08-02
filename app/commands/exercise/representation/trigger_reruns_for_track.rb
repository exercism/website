class Exercise::Representation::TriggerRerunsForTrack
  include Mandate

  initialize_with :track

  def call
    reps = Exercise::Representation.where(track:).with_feedback.
      includes(source_submission: :exercise).select(:id, :source_submission_id)

    reps.find_each do |representation|
      submission = representation.source_submission

      # Always use the exercise git_sha here, not the submission one.
      # We want to run against the latest version.
      Submission::Representation::Init.(submission, type: :exercise, git_sha: submission.exercise.git_sha, run_in_background: true)
    end
  end
end
