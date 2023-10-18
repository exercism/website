class Submission::Representation::TriggerRerunsForExercise
  include Mandate

  queue_as :background

  initialize_with :exercise

  def call
    exercise.iterations.includes(:submission).find_each do |iteration|
      Submission::Representation::Init.(iteration.submission, type: :exercise, git_sha:, run_in_background: true)
    end
  end

  # Always use the exercise git_sha here, not the submission one.
  # We want to run against the latest version.
  delegate :git_sha, to: :exercise
end
