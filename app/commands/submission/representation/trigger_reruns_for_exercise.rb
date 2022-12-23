class Submission::Representation::TriggerRerunsForExercise
  include Mandate

  queue_as :dribble

  initialize_with :exercise

  def call
    Submission.where(exercise:).find_each do |submission|
      Submission::Representation::Init.(submission, type: :exercise, git_sha: exercise.git_sha, run_in_background: true)
    end
  end
end
