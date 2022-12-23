class Exercise::Representation::TriggerRerunsForTrack
  include Mandate

  initialize_with :track

  def call
    Exercise::Representation.where(track:).with_feedback.includes(source_submission: :exercise).find_each do |representation|
      submission = representation.source_submission
      Submission::Representation::Init.(submission, type: :exercise, git_sha: submission.exercise.git_sha, run_in_background: true)
    end
  end
end
