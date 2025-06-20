class Exercise::Representation::UpdateNumSubmissions
  include Mandate

  queue_as :solution_processing

  initialize_with :representation

  def call
    representation.update!(num_submissions:)
  end

  private
  def num_submissions
    # It's very computationally expensive to work this out
    # for hello world where there are generally hundreds of
    # thousands of identical solutions. So we just ignore this.
    return 0 if representation.exercise.slug == "hello-world"

    representation.submission_representations.joins(:submission).
      where(submissions: { tests_status: :passed }).
      select(:submission_id).distinct.count
  end
end
