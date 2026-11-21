class Exercise::Representation::TriggerRerunsForTrack
  include Mandate

  initialize_with :track

  def call
    rerun_representations_with_feedback!
    rerun_unrepresentable_submissions!
  end

  private
  def rerun_representations_with_feedback!
    reps = Exercise::Representation.where(track:).with_feedback.
      includes(source_submission: :exercise).select(:id, :source_submission_id)

    reps.find_each do |representation|
      submission = representation.source_submission

      # Always use the exercise git_sha here, not the submission one.
      # We want to run against the latest version.
      Submission::Representation::Init.(submission, type: :exercise, git_sha: submission.exercise.git_sha, run_in_background: true)
    end
  end

  # A new version of the representer might be able to represent these now,
  # so we run them again as if they had just been submitted.
  def rerun_unrepresentable_submissions!
    track.submissions.representation_unrepresentable.find_each do |submission|
      Submission::Representation::Init.(submission, run_in_background: true)
    end
  end
end
