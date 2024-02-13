class Metrics::SubmitSubmissionMetric < Metric
  params :submission

  delegate :exercise, to: :submission

  def guard_params = submission.id

  after_create do
    Metrics.increment_num_submissions!
  end
end
