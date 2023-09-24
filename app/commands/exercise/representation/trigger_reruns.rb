class Exercise::Representation::TriggerReruns
  include Mandate

  queue_as :background

  initialize_with :exercise_representation, :git_sha

  def call
    submission_representations.find_each do |submission_representation|
      Submission::Representation::Init.(
        submission_representation.submission,
        run_in_background: true
      )
    end
  end

  def submission_representations
    exercise_representation.submission_representations.
      where('submissions.git_sha': git_sha).
      includes(:submission)
  end
end
