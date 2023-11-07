class Exercise::Representation::UpdateNumSubmissions
  include Mandate

  queue_as :solution_processing

  initialize_with :representation

  def call
    representation.update!(num_submissions:)
  end

  private
  def num_submissions
    representation.submission_representations.joins(:submission).
      where(submissions: { tests_status: :passed }).
      select(:submission_id).distinct.count
  end
end
